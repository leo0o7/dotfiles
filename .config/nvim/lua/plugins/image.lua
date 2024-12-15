return {
	{
		"vhyrro/luarocks.nvim",
		priority = 1001, -- this plugin needs to run before anything else
		opts = {
			rocks = { "magick" },
		},
	},
	{
		"3rd/image.nvim",
		dependencies = { "luarocks.nvim" },
		config = function()
			require("image").setup({
				backend = "kitty",
				kitty_method = "normal",
				-- avoid double rendering in tmux
				-- (image stays render in different nvim windows)
				tmux_show_only_in_active_window = true,
				-- toggles images when windows are overlapped-- toggles images when windows are overlapped
				window_overlap_clear_enable = true,
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = false,
						-- render url images
						download_remote_images = true,
						-- only render image at cursor
						-- with many images it can be slow
						only_render_image_at_cursor = true,
						-- markdown extensions (ie. quarto) can go here
						filetypes = { "markdown" },
					},
				},
			})
		end,
	},
}
