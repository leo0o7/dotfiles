return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
	keys = {
		{ "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history" },
	},
	opts = {
		enhanced_diff_hl = true,
		use_icons = true,
		keymaps = {
			disable_defaults = false,
			view = {
				["<leader>e"] = false,
				{ "n", "<leader>E", "<cmd>DiffviewFocusFiles<cr>", { desc = "Focus file panel" } },
				{ "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
			file_history_panel = {
				["<leader>e"] = false,
				{ "n", "<leader>E", "<cmd>DiffviewFocusFiles<cr>", { desc = "Focus file panel" } },
				{ "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
			},
			file_panel = {
				["<leader>e"] = false,
				{ "n", "<leader>E", "<cmd>DiffviewFocusFiles<cr>", { desc = "Focus file panel" } },
				{ "n", "<leader>q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
				{ "n", "s", false }, -- disable stage entry
				{ "n", "S", false }, -- disable stage all
				{ "n", "U", false }, -- disable unstage all
			},
		},
	},
}
