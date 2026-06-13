return {
	black = 0xff1a1b26, -- Darker background like TokyoNight
	white = 0xffc0caf5, -- Soft white-blueish tone
	red = 0xfff7768e, -- TokyoNight red
	green = 0xff9ece6a, -- TokyoNight green
	blue = 0xff7aa2f7, -- TokyoNight blue
	yellow = 0xffe0af68, -- TokyoNight yellow
	orange = 0xffff9e64, -- TokyoNight orange
	magenta = 0xffbb9af7, -- TokyoNight magenta
	grey = 0xff565f89, -- TokyoNight grey
	transparent = 0x00000000,

	bar = {
		-- bg = 0xff1a1b26, -- Darker TokyoNight background for the bar
		bg = 0xff181826, -- Darker TokyoNight background for the bar
		border = 0xff3b4261, -- Darker border matching TokyoNight theme
	},
	popup = {
		bg = 0xff1a1b26, -- Popup background
		border = 0xff565f89, -- Popup border matching the TokyoNight grey
	},
	bg1 = 0xff24283b, -- Slightly lighter background (TokyoNight's main background)
	bg2 = 0xff1a1b26, -- Darker background shade for contrast
	bg3 = 0xff2d3246, -- Subtle highlight for occupied workspaces

	-- black = 0xff10333f, -- Darker background like TokyoNight
	-- white = 0xffece8d6, -- Soft white-blueish tone
	-- red = 0xffca4238, -- TokyoNight red
	-- green = 0xff88982e, -- TokyoNight green
	-- blue = 0xff4689cc, -- TokyoNight blue
	-- yellow = 0xffae8a2d, -- TokyoNight yellow
	-- orange = 0xffff9e64, -- TokyoNight orange
	-- magenta = 0xffc24380, -- TokyoNight magenta
	-- grey = 0xff869395, -- TokyoNight grey
	-- transparent = 0x00000000,
	--
	-- bar = {
	-- 	bg = 0xff00141a, -- Darker TokyoNight background for the bar
	-- 	border = 0xff10333f, -- Darker border matching TokyoNight theme
	-- },
	-- popup = {
	-- 	bg = 0xff0b2732, -- Popup background
	-- 	border = 0xff10333f, -- Popup border matching the TokyoNight grey
	-- },
	-- bg1 = 0xff10333f, -- Slightly lighter background (TokyoNight's main background)
	-- bg2 = 0xff0b2732, -- Darker background shade for contrast

	-- black = 0xff282828,
	-- white = 0xffebdbb2,
	-- red = 0xffcc241d,
	-- green = 0xff98971a,
	-- blue = 0xff458588,
	-- yellow = 0xffd79921,
	-- orange = 0xffd65d0e,
	-- magenta = 0xffb16286,
	-- grey = 0xffa89984,
	-- transparent = 0x00000000,
	--
	-- bar = {
	-- 	bg = 0xff1d2021,
	-- 	border = 0xff1d2021,
	-- },
	-- popup = {
	-- 	bg = 0xff32302f,
	-- 	border = 0xff7c6f64,
	-- },
	-- bg1 = 0xff282828,
	-- bg2 = 0xff1d2021,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
