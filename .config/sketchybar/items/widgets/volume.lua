local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250

local volume_percent = sbar.add("item", "widgets.volume1", {
	position = "right",
	icon = { drawing = false },
	label = {
		string = "??%",
		padding_left = -1,
		font = { family = settings.font.numbers },
	},
})

local volume_icon = sbar.add("item", "widgets.volume2", {
	position = "right",
	padding_right = -1,
	icon = {
		string = icons.volume._100,
		width = 0,
		align = "left",
		color = colors.grey,
		font = {
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
	},
	label = {
		width = 25,
		align = "left",
		font = {
			family = settings.font.icons,
			style = "Regular",
			size = 14.0,
		},
	},
})

local volume_bracket = sbar.add("bracket", "widgets.volume.bracket", {
	volume_icon.name,
	volume_percent.name,
}, {
	background = { color = colors.bg1 },
	popup = { align = "center" },
})

sbar.add("item", "widgets.volume.padding", {
	position = "right",
	width = settings.group_paddings,
})

local volume_slider = sbar.add("slider", popup_width, {
	position = "popup." .. volume_bracket.name,
	slider = {
		highlight_color = colors.blue,
		background = {
			height = 6,
			corner_radius = 3,
			color = colors.bg2,
		},
		knob = {
			string = "􀀁",
			drawing = true,
		},
	},
	background = { color = colors.bg1, height = 2, y_offset = -20 },
	click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

-- Map device name → SF Symbol character.
-- Adjust these in the SF Symbols app if needed.
local function device_icon_for(name)
	local l = name:lower()
	if l:find("airpods pro") then
		return "􀟥" -- airpodspro
	elseif l:find("airpods") then
		return "􀟤" -- airpods
	elseif l:find("headphone") or l:find("headset") or l:find("earpod") then
		return "􀐱" -- headphones
	elseif l:find("homepod") then
		return "􀟸" -- hifispeaker.fill
	elseif l:find("macbook") or l:find("built%-in") or l:find("internal") then
		return "􀣺" -- laptopcomputer  (close enough for built-in)
	elseif l:find("display") or l:find("hdmi") or l:find("thunderbolt") then
		return "􀎲" -- tv
	elseif l:find("bluetooth") then
		return "􀑵" -- dot.radiowaves.left.and.right
	elseif l:find("usb") then
		return "􀠄" -- cable.connector
	elseif l:find("aggregate") or l:find("multi") then
		return "􀾲" -- square.stack.3d.up
	else
		return "􀊩" -- speaker.wave.2 (default)
	end
end

local function mic_icon_for(name)
	local l = name:lower()
	if l:find("airpods pro") then
		return "􀟥"
	elseif l:find("airpods") then
		return "􀟤"
	elseif l:find("built%-in") or l:find("internal") or l:find("macbook") then
		return "􀊰" -- mic
	elseif l:find("usb") then
		return "􀊰"
	else
		return "􀊰" -- mic (default)
	end
end

-- Section divider — thin line + small caps label
local function make_section_header(id, label_str)
	sbar.add("item", id, {
		position = "popup." .. volume_bracket.name,
		width = popup_width,
		align = "center",
		icon = { drawing = false },
		label = {
			string = label_str,
			color = colors.grey,
			font = {
				style = settings.font.style_map["Bold"],
				size = 9.0,
			},
			padding_left = 10,
		},
		background = {
			height = 1,
			color = colors.with_alpha(colors.grey, 0.3),
			y_offset = -14,
		},
		padding_top = 4,
	})
end

-- A single device row: SF symbol icon on the left, name on the right,
-- checkmark appended when active. Mimics the macOS sound picker layout.
local function make_device_row(id, device_name, is_active, icon_str, click_script)
	local label_color = is_active and colors.white or colors.with_alpha(colors.white, 0.55)
	local icon_color = is_active and colors.blue or colors.with_alpha(colors.white, 0.4)
	local display_name = is_active and (device_name .. "  ✓") or device_name

	sbar.add("item", id, {
		position = "popup." .. volume_bracket.name,
		width = popup_width,
		align = "left",
		padding_left = 6,
		padding_right = 6,
		icon = {
			string = icon_str,
			color = icon_color,
			width = 28,
			align = "center",
			font = {
				style = settings.font.style_map["Regular"],
				size = 15.0,
			},
		},
		label = {
			string = display_name,
			color = label_color,
			align = "left",
			font = {
				family = settings.font.text,
				style = is_active and settings.font.style_map["Semibold"] or settings.font.style_map["Regular"],
				size = 12.0,
			},
			padding_left = 4,
		},
		background = {
			color = colors.transparent,
			corner_radius = 6,
			height = 24,
		},
		click_script = click_script,
	})
end

volume_percent:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)
	local icon = icons.volume._0
	if volume > 60 then
		icon = icons.volume._100
	elseif volume > 30 then
		icon = icons.volume._66
	elseif volume > 10 then
		icon = icons.volume._33
	elseif volume > 0 then
		icon = icons.volume._10
	end

	local lead = ""
	if volume < 10 then
		lead = "0"
	end

	volume_icon:set({ label = icon })
	volume_percent:set({ label = lead .. volume .. "%" })
	volume_slider:set({ slider = { percentage = volume } })
end)

local function volume_collapse_details()
	if volume_bracket:query().popup.drawing ~= "on" then
		return
	end
	volume_bracket:set({ popup = { drawing = false } })
	sbar.remove("/volume\\.section\\.*/")
	sbar.remove("/volume\\.device\\.*/")
	sbar.remove("/volume\\.input\\.*/")
end

local function volume_toggle_details(env)
	if env.BUTTON == "right" then
		sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
		return
	end

	if volume_bracket:query().popup.drawing ~= "off" then
		volume_collapse_details()
		return
	end

	volume_bracket:set({ popup = { drawing = true } })

	make_section_header("volume.section.output", "OUTPUT")

	sbar.exec("SwitchAudioSource -t output -c", function(current_out)
		local current_out_name = current_out:sub(1, -2)

		sbar.exec("SwitchAudioSource -a -t output", function(available_out)
			local counter = 0
			for device in string.gmatch(available_out, "[^\r\n]+") do
				local is_active = (device == current_out_name)
				-- click_script recolors rows via sketchybar then switches source
				local click = 'SwitchAudioSource -t output -s "'
					.. device
					.. '" && sketchybar --set /volume.device\\.*/ icon.color='
					.. colors.with_alpha(colors.white, 0.4)
					.. " label.color="
					.. colors.with_alpha(colors.white, 0.55)
					.. " --set $NAME icon.color="
					.. colors.blue
					.. " label.color="
					.. colors.white
				make_device_row("volume.device." .. counter, device, is_active, device_icon_for(device), click)
				counter = counter + 1
			end

			make_section_header("volume.section.input", "INPUT")

			sbar.exec("SwitchAudioSource -t input -c", function(current_in)
				local current_in_name = current_in:sub(1, -2)

				sbar.exec("SwitchAudioSource -a -t input", function(available_in)
					local input_counter = 0
					for device in string.gmatch(available_in, "[^\r\n]+") do
						local is_active = (device == current_in_name)
						local click = 'SwitchAudioSource -t input -s "'
							.. device
							.. '" && sketchybar --set /volume.input\\.*/ icon.color='
							.. colors.with_alpha(colors.white, 0.4)
							.. " label.color="
							.. colors.with_alpha(colors.white, 0.55)
							.. " --set $NAME icon.color="
							.. colors.blue
							.. " label.color="
							.. colors.white
						make_device_row(
							"volume.input." .. input_counter,
							device,
							is_active,
							mic_icon_for(device),
							click
						)
						input_counter = input_counter + 1
					end
				end)
			end)
		end)
	end)
end

local function volume_scroll(env)
	local delta = env.SCROLL_DELTA
	sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe("mouse.clicked", volume_toggle_details)
volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_percent:subscribe("mouse.clicked", volume_toggle_details)
volume_percent:subscribe("mouse.exited.global", volume_collapse_details)
volume_percent:subscribe("mouse.scrolled", volume_scroll)
