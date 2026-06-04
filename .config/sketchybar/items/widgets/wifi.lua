local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

sbar.exec(
	"killall network_load 2>/dev/null; "
		.. "$CONFIG_DIR/helpers/event_providers/network_load/bin/network_load en0 network_update 2.0"
)

local CONFIG_DIR = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")
local WIFI_SCAN = CONFIG_DIR .. "/helpers/wifi_scan/wifi_scan.sh"
local CACHE = "/tmp/sketchybar_wifi.json"
local POLL_SECS = 7 -- rescan interval while popup is open
local popup_width = 280

-- ─── state ────────────────────────────────────────────────────────────────────
local connecting = false -- true while a connect attempt is in flight
local popup_open = false -- true while popup is visible
local scan_active = false -- true while wifi_scan.sh is running
local poll_gen = 0 -- incremented on close; stale callbacks check this

-- ─── bar items ────────────────────────────────────────────────────────────────

local wifi_up = sbar.add("item", "widgets.wifi1", {
	position = "right",
	padding_left = -5,
	width = 0,
	icon = {
		padding_right = 0,
		font = { style = settings.font.style_map["Bold"], size = 9.0 },
		string = icons.wifi.upload,
	},
	label = {
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		color = colors.red,
		string = "??? Bps",
	},
	y_offset = 4,
})

local wifi_down = sbar.add("item", "widgets.wifi2", {
	position = "right",
	padding_left = -5,
	icon = {
		padding_right = 0,
		font = { style = settings.font.style_map["Bold"], size = 9.0 },
		string = icons.wifi.download,
	},
	label = {
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 9.0,
		},
		color = colors.blue,
		string = "??? Bps",
	},
	y_offset = -4,
})

local wifi = sbar.add("item", "widgets.wifi.padding", {
	position = "right",
	label = { drawing = false },
})

local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", { wifi.name, wifi_up.name, wifi_down.name }, {
	background = { color = colors.bg1 },
	popup = { align = "center", height = 30 },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

-- ─── static popup rows ────────────────────────────────────────────────────────

local ssid_item = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = { font = { style = settings.font.style_map["Bold"] }, string = icons.wifi.router },
	width = popup_width,
	align = "center",
	label = {
		font = { size = 15, style = settings.font.style_map["Bold"] },
		max_chars = 24,
		string = "—",
	},
	background = { height = 2, color = colors.grey, y_offset = -15 },
})

local hostname = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = { align = "left", string = "Hostname:", width = popup_width / 2 },
	label = { max_chars = 20, string = "—", width = popup_width / 2, align = "right" },
})

local ip = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = { align = "left", string = "IP:", width = popup_width / 2 },
	label = { string = "—", width = popup_width / 2, align = "right" },
})

local mask = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = { align = "left", string = "Subnet mask:", width = popup_width / 2 },
	label = { string = "—", width = popup_width / 2, align = "right" },
})

local router_item = sbar.add("item", {
	position = "popup." .. wifi_bracket.name,
	icon = { align = "left", string = "Router:", width = popup_width / 2 },
	label = { string = "—", width = popup_width / 2, align = "right" },
})

-- Always-visible scan-status row (appears below the network list)
local scan_status = sbar.add("item", "wifi.scan.status", {
	position = "popup." .. wifi_bracket.name,
	drawing = false, -- shown only while popup is open
	width = popup_width,
	align = "center",
	icon = { drawing = false },
	label = {
		string = "↻ Scanning…",
		color = colors.grey,
		font = { style = settings.font.style_map["Regular"], size = 9.0 },
	},
})

-- ─── signal helpers ───────────────────────────────────────────────────────────

--  ≥ -55  excellent (4 dots, green)
--  ≥ -67  good      (3 dots, yellow)
--  ≥ -80  fair      (2 dots, orange)
--   < -80  weak      (1 dot,  red)

local function rssi_color(rssi)
	if rssi >= -55 then
		return colors.green
	elseif rssi >= -67 then
		return colors.yellow
	elseif rssi >= -80 then
		return colors.orange
	else
		return colors.red
	end
end

local function signal_dots(rssi)
	if rssi >= -55 then
		return "●●●●"
	elseif rssi >= -67 then
		return "●●●○"
	elseif rssi >= -80 then
		return "●●○○"
	else
		return "●○○○"
	end
end

-- ─── utilities ────────────────────────────────────────────────────────────────

local function trim(s)
	return s and s:match("^%s*(.-)%s*$") or ""
end

local function read_cache()
	local f = io.open(CACHE, "r")
	if not f then
		return nil
	end
	local c = f:read("*a")
	f:close()
	c = trim(c)
	return c ~= "" and c or nil
end

local function parse_networks(json)
	if not json then
		return {}
	end
	local results = {}
	for obj in json:gmatch("{([^}]+)}") do
		local ssid = obj:match('"ssid"%s*:%s*"([^"]*)"')
		local rssi = tonumber(obj:match('"rssi"%s*:%s*(-?%d+)'))
		local security = obj:match('"security"%s*:%s*"([^"]*)"') or "none"
		local connected = obj:find('"connected"%s*:%s*true') ~= nil
		local preferred = obj:find('"preferred"%s*:%s*true') ~= nil
		if ssid and ssid ~= "" and rssi then
			results[#results + 1] = {
				ssid = ssid,
				rssi = rssi,
				security = security,
				connected = connected,
				preferred = preferred,
			}
		end
	end
	return results
end

-- ─── popup open / close ───────────────────────────────────────────────────────

local function cleanup_rows()
	sbar.remove("/wifi\\.net\\.*/")
	sbar.remove("wifi.section.header")
	scan_status:set({ drawing = false })
end

local function hide_popup()
	if not popup_open then
		return
	end
	popup_open = false
	poll_gen = poll_gen + 1 -- invalidate pending poll ticks
	wifi_bracket:set({ popup = { drawing = false } })
	cleanup_rows()
end

-- ─── connect flow ─────────────────────────────────────────────────────────────

local function connect_to(row_name, ssid, security, plain_label)
	if connecting then
		return
	end
	connecting = true

	local sh_esc = ssid:gsub("'", "'\\''") -- safe for single-quoted shell

	-- unblock after 30 s if something hangs
	sbar.delay(30, function()
		if connecting then
			connecting = false
		end
	end)

	local function set_row(lbl, col)
		sbar.set(row_name, { label = { string = lbl, color = col } })
	end
	local function restore()
		set_row(plain_label, colors.white)
	end
	local function on_success()
		connecting = false
		set_row("Connected  " .. "􀆅", colors.green)
		sbar.delay(1.5, hide_popup)
	end
	local function on_fail(msg)
		connecting = false
		set_row(msg, colors.red)
		sbar.delay(2.5, restore)
	end

	-- step 1: try without password (works for open nets + Keychain-saved)
	set_row("Connecting…", colors.yellow)
	sbar.exec(string.format("networksetup -setairportnetwork en0 '%s' 2>&1", sh_esc), function(r1)
		r1 = trim(r1)
		if r1 == "" then
			on_success()
			return
		end
		if security == "none" then
			on_fail("Failed to connect")
			return
		end
		-- step 2: secured network, not in Keychain → prompt
		connecting = false
		restore()
		local as_esc = ssid:gsub('"', '\\"')
		local dialog = string.format(
			"osascript"
				.. " -e 'try'"
				.. ' -e \'text returned of (display dialog "Password for \\"%s\\":" '
				.. 'default answer "" with hidden answer '
				.. 'buttons {"Cancel","Join"} default button "Join" '
				.. 'with title "Join Wi-Fi")\''
				.. " -e 'on error'"
				.. " -e '\"__CANCELLED__\"'"
				.. " -e 'end try'",
			as_esc
		)
		sbar.exec(dialog, function(pwd)
			pwd = trim(pwd)
			if pwd == "__CANCELLED__" or pwd == "" then
				return
			end
			connecting = true
			set_row("Connecting…", colors.yellow)
			local pw_esc = pwd:gsub("'", "'\\''")
			sbar.exec(string.format("networksetup -setairportnetwork en0 '%s' '%s' 2>&1", sh_esc, pw_esc), function(r2)
				r2 = trim(r2)
				if r2 == "" then
					on_success()
				else
					on_fail("Incorrect password")
				end
			end)
		end)
	end)
end

-- ─── network row factory ──────────────────────────────────────────────────────

local function make_row(id, ssid, rssi, security, is_connected)
	local badge = (security ~= "none") and " 􀎠" or ""
	local plain = ssid .. badge
	local label_str, label_col, label_style
	if is_connected then
		label_str = plain .. "  " .. "􀆅"
		label_col = colors.white
		label_style = settings.font.style_map["Semibold"]
	else
		label_str = plain
		label_col = colors.white -- dimming via colors.with_alpha isn't always available
		label_style = settings.font.style_map["Regular"]
	end

	local row = sbar.add("item", id, {
		position = "popup." .. wifi_bracket.name,
		width = popup_width,
		align = "left",
		padding_left = 6,
		padding_right = 6,
		icon = {
			string = signal_dots(rssi),
			color = rssi_color(rssi),
			width = 38,
			align = "center",
			font = {
				family = settings.font.numbers,
				style = settings.font.style_map["Regular"],
				size = 10.0,
			},
		},
		label = {
			string = label_str,
			color = label_col,
			align = "left",
			padding_left = 4,
			font = { family = settings.font.text, style = label_style, size = 12.0 },
		},
		background = { color = colors.transparent, corner_radius = 6, height = 24 },
	})

	if not is_connected then
		local rid = id -- captured by value for the closure
		local rssid = ssid
		local rsec = security
		local rlbl = plain
		row:subscribe("mouse.clicked", function(_)
			if not connecting then
				connect_to(rid, rssid, rsec, rlbl)
			end
		end)
	end
end

-- ─── populate rows from cache ─────────────────────────────────────────────────

local function populate(show_spinner)
	cleanup_rows()

	-- section header
	sbar.add("item", "wifi.section.header", {
		position = "popup." .. wifi_bracket.name,
		width = popup_width,
		align = "center",
		icon = { drawing = false },
		label = {
			string = "NETWORKS",
			color = colors.grey,
			font = { style = settings.font.style_map["Bold"], size = 9.0 },
		},
		background = { height = 1, color = colors.grey, y_offset = -14 },
		padding_top = 4,
	})

	local networks = parse_networks(read_cache())

	if #networks == 0 then
		sbar.add("item", "wifi.net.empty", {
			position = "popup." .. wifi_bracket.name,
			width = popup_width,
			align = "center",
			icon = { drawing = false },
			label = {
				string = show_spinner and "Scanning…" or "No networks found",
				color = colors.grey,
				font = { style = settings.font.style_map["Regular"], size = 12.0 },
			},
		})
	else
		for i, net in ipairs(networks) do
			make_row("wifi.net." .. i, net.ssid, net.rssi, net.security, net.connected)
		end
	end

	-- scan status footer
	scan_status:set({
		drawing = true,
		label = { string = show_spinner and "↻ Scanning…" or "Updated just now" },
	})
end

-- ─── scan + polling loop ──────────────────────────────────────────────────────

local function do_scan(gen)
	if scan_active then
		return
	end
	scan_active = true
	scan_status:set({ drawing = true, label = { string = "↻ Scanning…" } })

	sbar.exec("bash '" .. WIFI_SCAN .. "' 2>/dev/null", function()
		scan_active = false
		if not popup_open or poll_gen ~= gen then
			return
		end
		populate(false)
	end)
end

local function start_poll()
	local gen = poll_gen
	do_scan(gen)

	local function tick()
		if not popup_open or poll_gen ~= gen then
			return
		end
		if not connecting then
			do_scan(gen)
		end
		sbar.delay(POLL_SECS, tick)
	end
	sbar.delay(POLL_SECS, tick)
end

-- ─── popup toggle ─────────────────────────────────────────────────────────────

local function show_popup()
	popup_open = true
	wifi_bracket:set({ popup = { drawing = true } })

	-- show cached data instantly, with spinner
	populate(true)

	-- static connection details (async, fine to be slightly delayed)
	sbar.exec("networksetup -getcomputername 2>/dev/null", function(r)
		local v = trim(r)
		hostname:set({ label = v ~= "" and v or "N/A" })
	end)
	sbar.exec("ipconfig getifaddr en0 2>/dev/null", function(r)
		local v = trim(r)
		ip:set({ label = v ~= "" and v or "N/A" })
	end)
	sbar.exec("ipconfig getsummary en0 2>/dev/null | awk -F' SSID : ' '/ SSID : /{print $2}'", function(r)
		local v = trim(r)
		ssid_item:set({ label = v ~= "" and v or "Not connected" })
	end)
	sbar.exec("networksetup -getinfo Wi-Fi 2>/dev/null | awk -F': ' '/^Subnet mask:/{print $2}'", function(r)
		local v = trim(r)
		mask:set({ label = v ~= "" and v or "N/A" })
	end)
	sbar.exec("networksetup -getinfo Wi-Fi 2>/dev/null | awk -F': ' '/^Router:/{print $2}'", function(r)
		local v = trim(r)
		router_item:set({ label = v ~= "" and v or "N/A" })
	end)

	start_poll()
end

local function toggle_popup()
	if popup_open then
		hide_popup()
	else
		show_popup()
	end
end

-- ─── speed subscription ───────────────────────────────────────────────────────

wifi_up:subscribe("network_update", function(env)
	local uc = (env.upload == "000 Bps") and colors.grey or colors.red
	local dc = (env.download == "000 Bps") and colors.grey or colors.blue
	wifi_up:set({ icon = { color = uc }, label = { string = env.upload, color = uc } })
	wifi_down:set({ icon = { color = dc }, label = { string = env.download, color = dc } })
end)

wifi:subscribe({ "wifi_change", "system_woke" }, function(_)
	sbar.exec("ipconfig getifaddr en0 2>/dev/null", function(addr)
		local c = trim(addr) ~= ""
		wifi:set({
			icon = {
				string = c and icons.wifi.connected or icons.wifi.disconnected,
				color = c and colors.white or colors.red,
			},
		})
	end)
end)

-- pre-warm cache on startup
sbar.exec("bash '" .. WIFI_SCAN .. "' &")

-- ─── click + hover ────────────────────────────────────────────────────────────

wifi_up:subscribe("mouse.clicked", toggle_popup)
wifi_down:subscribe("mouse.clicked", toggle_popup)
wifi:subscribe("mouse.clicked", toggle_popup)

-- guard: don't dismiss while the password dialog is on screen
wifi:subscribe("mouse.exited.global", function()
	if not connecting then
		hide_popup()
	end
end)

-- ─── clipboard copy for static rows ──────────────────────────────────────────

local function copy_on_click(env)
	local label = sbar.query(env.NAME).label.value
	if not label or label == "" or label == "—" then
		return
	end
	sbar.exec(string.format("echo '%s' | pbcopy", label:gsub("'", "'\\''")))
	sbar.set(env.NAME, { label = { string = "Copied!", align = "center" } })
	sbar.delay(1, function()
		sbar.set(env.NAME, { label = { string = label, align = "right" } })
	end)
end

ssid_item:subscribe("mouse.clicked", copy_on_click)
hostname:subscribe("mouse.clicked", copy_on_click)
ip:subscribe("mouse.clicked", copy_on_click)
mask:subscribe("mouse.clicked", copy_on_click)
router_item:subscribe("mouse.clicked", copy_on_click)
