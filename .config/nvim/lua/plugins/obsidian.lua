-- require("obsidian").setup({ ui = { enable = false } })
return {
	-- {
	-- 	"epwalsh/obsidian.nvim",
	-- 	version = "*", -- recommended, use latest release instead of latest commit
	-- 	lazy = true,
	-- 	ft = "markdown",
	-- 	ui = {
	-- 		enable = false,
	-- 	},
	-- 	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- 	-- event = {
	-- 	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	-- 	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
	-- 	--   -- refer to `:h file-pattern` for more examples
	-- 	--   "BufReadPre path/to/my-vault/*.md",
	-- 	--   "BufNewFile path/to/my-vault/*.md",
	-- 	-- },
	-- 	dependencies = {
	-- 		-- Required.
	-- 		"nvim-lua/plenary.nvim",
	--
	-- 		-- see below for full list of optional dependencies
	-- 	},
	-- 	opts = {
	-- 		workspaces = {
	-- 			{
	-- 				name = "Anno 3",
	-- 				path = "/Users/leo/personal/notes/Anno 3/",
	-- 			},
	-- 			{
	-- 				name = "Anno 4",
	-- 				path = "/Users/leo/personal/notes/Anno 4/",
	-- 			},
	-- 		},
	-- 	},
	-- },
	--
	-- {
	dir = "~/obsidian-repeat",
	config = function()
		require("obsidian-repeat").setup({
			obsidian_server_address = "https://127.0.0.1:27124",
		})
	end,
	event = {
		"BufReadPre *.md",
		"BufNewFile *.md",
	},
	lazy = true,
	-- },
}
