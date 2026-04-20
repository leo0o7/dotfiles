-- force set language to english
-- vim.api.nvim_exec("language en_US", true)

-- set OSC 52 clipboard to avoid encoding issues on mac
vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = { "pbpaste" },
		["*"] = { "pbpaste" },
	},
}

require("config.lazy")
require("luasnip.loaders.from_lua").load({
	paths = { "~/.config/nvim/lua/snippets" },
})
