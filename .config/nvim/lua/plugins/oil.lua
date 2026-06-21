return {
	-- disable neo-tree even if LazyVim defaults try to enable it
	{ "nvim-neo-tree/neo-tree.nvim", enabled = false },
	{
		"barrettruth/canola.nvim",
		branch = "canola",
		lazy = false,

		init = function()
			vim.g.canola = {
				columns = {
					"git_status",
					"icon",
					-- "permissions",
					-- "size",
					-- "mtime",
				},
				extglob = true,
				view_options = {
					show_hidden = true,
				},
				float = {
					padding = 5,
				},
				delete = {
					recursive = true,
				},
			}
		end,
		keys = {
			{ "<leader>e", "<cmd>Canola --float<CR>", desc = "Explorer" },
		},
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			{
				"barrettruth/canola-collection",
				init = function()
					vim.g.canola_git = {
						show = {
							untracked = true,
							ignored = false,
						},
						format = "symbol", -- "compact" | "symbol" | "porcelain"
					}
				end,
			},
		},
	},
}
