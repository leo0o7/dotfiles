return {
	{
		"ibhagwan/fzf-lua",
		opts = function()
			local actions = require("fzf-lua.actions")

			return {
				"borderless-full",
				actions = {
					files = {
						true,
						["ctrl-g"] = { fn = actions.toggle_ignore, reuse = true, header = false },
					},
				},
			}
		end,
	},
}
