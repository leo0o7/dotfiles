return {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	event = "VeryLazy",
	keys = {
		{ "<leader>e", ":Neotree toggle float<CR>", silent = true, desc = "Float File Explorer" },
		{
			"<leader>ef",
			":Neotree reveal float<CR>",
			silent = true,
			desc = "Float File Explorer and reveal current file",
		},
		{ "<leader><tab>", ":Neotree toggle right<CR>", silent = true, desc = "Right File Explorer" },
	},
	config = function()
		require("neo-tree").setup({
			position = "right",
			close_if_last_window = true,
			popup_border_style = "single",
			enable_git_status = true,
			enable_modified_markers = true,
			enable_diagnostics = true,
			sort_case_insensitive = true,
			default_component_configs = {
				indent = {
					with_markers = true,
					with_expanders = true,
				},
				modified = {
					symbol = "⊕",
					highlight = "NeoTreeModified",
				},
				window = {
					position = "float",
					width = 35,
				},
				git_status = {
					symbols = {
						added = "✚",
						modified = "✹",
						deleted = "✖",
						updated = "",
						untracked = "✭",
						ignored = "◌",
					},
				},
				filesystem = {
					use_libuv_file_watcher = true,
					filtered_items = {
						hide_dotfiles = false,
						hide_gitignored = false,
						hide_by_name = {
							"node_modules",
						},
						never_show = {
							".git",
							".svn",
							".hg",
							"CVS",
							"Thumbs.db",
							".next",
							".husky",
							"drizzle",
							"dist",
							".todo.md",
							".vscode",
							".eslintrc.cjs",
							".editorconfig",
							".gitignore",
							".lintstagedrc.mjs",
							".markdownlint.json",
							".markdownlintignore",
							".prettierignore",
							"bun.lockb",
							"cspell.json",
							"package-lock.json",
							"pnpm-lock.yaml",
							"next-env.d.ts",
							"postcss.config.cjs",
							"prettier.config.js",
							"README.md",
							"next.config.js",
							"drizzle.config.ts",
							"migrate.ts",
							".env.example",
							"next.config.mjs",
							".eslintrc.json",
							"out",
							"postcss.config.mjs",
							".DS_Store",
							"thumbs.db",
						},
					},
				},
				source_selector = {
					winbar = true,
					sources = {
						{ source = "filesystem", display_name = " ?  Files " },
						{ source = "buffers", display_name = " ?  Bufs " },
						{ source = "git_status", display_name = " ?  Git " },
					},
				},
				event_handlers = {
					{
						event = "neo_tree_window_after_open",
						handler = function(args)
							if args.position == "left" or args.position == "right" then
								vim.cmd("wincmd =")
							end
						end,
					},
					{
						event = "neo_tree_window_after_close",
						handler = function(args)
							if args.position == "left" or args.position == "right" then
								vim.cmd("wincmd =")
							end
						end,
					},
				},
			},
		})
	end,
}
