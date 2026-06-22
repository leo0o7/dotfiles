-- force set language to english
-- vim.api.nvim_exec("language en_US", true)
require("config.lazy")

-- HACK: LazyVim's FileType autocmd for treesitter folding is
-- created too late for the first markdown file opened in a session.
-- This runs at init time and catches every file.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	group = vim.api.nvim_create_augroup("markdown_fold_fix", { clear = true }),
	callback = function()
		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "v:lua.LazyVim.treesitter.foldexpr()"
	end,
})

require("luasnip.loaders.from_lua").load({
	paths = { "~/.config/nvim/lua/snippets" },
})
