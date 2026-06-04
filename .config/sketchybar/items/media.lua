local icons = require("icons")
local colors = require("colors")

local CONFIG_DIR = os.getenv("CONFIG_DIR") or (os.getenv("HOME") .. "/.config/sketchybar")

local whitelist = {
	["com.spotify.client"] = true,
	["com.apple.Music"] = true,
}

local function truncate(str, max)
	if not str or str == "" then
		return ""
	end
	if #str > max then
		return str:sub(1, max - 1) .. "…"
	end
	return str
end

sbar.add("event", "media_update")
sbar.exec(
	"killall -f media_provider.sh 2>/dev/null; nohup bash '"
		.. CONFIG_DIR
		.. "/helpers/media_provider/media_provider.sh' > /tmp/sketchybar_media.log 2>&1 &"
)

local media_cover = sbar.add("item", "media_cover", {
	position = "right",
	background = {
		image = { string = "", scale = 1.0 },
		color = colors.transparent,
		height = 26,
		corner_radius = 4,
	},
	label = { drawing = false },
	icon = { drawing = false },
	drawing = false,
	updates = true,
	popup = { align = "center", horizontal = true },
})

local media_artist = sbar.add("item", {
	position = "right",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	width = 0,
	icon = { drawing = false },
	label = {
		width = 0,
		font = { size = 9 },
		color = colors.with_alpha(colors.white, 0.6),
		max_chars = 18,
		y_offset = 6,
	},
})

local media_title = sbar.add("item", {
	position = "right",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = { size = 11 },
		width = 0,
		max_chars = 16,
		y_offset = -5,
	},
})

sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.back },
	label = { drawing = false },
	click_script = "/opt/homebrew/bin/media-control previous-track",
})
sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.play_pause },
	label = { drawing = false },
	click_script = "/opt/homebrew/bin/media-control toggle-play-pause",
})
sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.forward },
	label = { drawing = false },
	click_script = "/opt/homebrew/bin/media-control next-track",
})

local interrupt = 0
local hide_generation = 0
local hide_pending = false

local function hide_media()
	media_artist:set({ drawing = false, label = { string = "" } })
	media_title:set({ drawing = false, label = { string = "" } })
	media_cover:set({
		drawing = false,
		background = { image = { string = "" } },
		popup = { drawing = false },
	})
end

local function schedule_hide()
	if hide_pending then
		return
	end

	hide_pending = true
	hide_generation = hide_generation + 1
	local generation = hide_generation

	sbar.delay(60, function()
		if hide_pending and generation == hide_generation then
			hide_pending = false
			hide_media()
		end
	end)
end

local function cancel_hide()
	hide_pending = false
	hide_generation = hide_generation + 1
end

local function animate_detail(detail)
	if not detail then
		interrupt = interrupt - 1
	end
	if interrupt > 0 and not detail then
		return
	end
	sbar.animate("tanh", 30, function()
		media_artist:set({ label = { width = detail and "dynamic" or 0 } })
		media_title:set({ label = { width = detail and "dynamic" or 0 } })
	end)
end

media_cover:subscribe("media_update", function(env)
	local playing = (env.state == "playing")
	local has_artwork = env.artwork and env.artwork ~= ""
	local has_title = env.title and env.title ~= ""
	local has_bundle = env.bundle and env.bundle ~= ""

	if not playing then
		if not has_title or not has_bundle or whitelist[env.bundle] then
			schedule_hide()
		end
		return
	end

	cancel_hide()

	-- only show for whitelisted apps
	if not whitelist[env.bundle] then
		hide_media()
		return
	end

	media_artist:set({ label = truncate(env.artist, 18) })
	media_title:set({ label = truncate(env.title, 16) })

	if has_artwork then
		media_cover:set({
			drawing = true,
			background = { image = { string = env.artwork, scale = 1.0 } },
		})
		media_artist:set({ drawing = true })
		media_title:set({ drawing = true })
		interrupt = 0
		animate_detail(true)
		interrupt = interrupt + 1
		sbar.delay(5, animate_detail)
	end
end)
media_cover:subscribe("mouse.entered", function()
	interrupt = interrupt + 1
	animate_detail(true)
end)
media_cover:subscribe("mouse.exited", function()
	animate_detail(false)
end)
media_cover:subscribe("mouse.clicked", function()
	media_cover:set({ popup = { drawing = "toggle" } })
end)
media_title:subscribe("mouse.exited.global", function()
	media_cover:set({ popup = { drawing = false } })
end)
