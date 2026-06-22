return {
	black = 0xff232136, -- Base
	white = 0xffe0def4, -- Text
	red = 0xffeb6f92, -- Love
	green = 0xff3e8fb0, -- Pine
	blue = 0xff9ccfd8, -- Foam
	yellow = 0xfff6c177, -- Gold
	orange = 0xffea9a97, -- Rose
	magenta = 0xffc4a7e7, -- Iris
	grey = 0xff6e6a86, -- Muted
	transparent = 0x00000000,

	bar = {
		bg = 0xff171523, -- Darkened Base (~65% brightness)
		border = 0xff44415a, -- Highlight Med
	},
	popup = {
		bg = 0xff2a273f, -- Surface
		border = 0xff6e6a86, -- Muted
	},
	bg1 = 0xff252339, -- ~40% toward Surface (inactive spaces)
	bg2 = 0xff232136, -- Base
	bg3 = 0xff302c45, -- ~40% toward Overlay (occupied spaces)

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
