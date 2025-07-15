local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- remove save keymap
keymap.del("n", "<C-s>")

keymap.set("n", "x", '"_x')
-- Increment/decrement (NOW USING DIAL)
-- keymap.set("n", "+", "<C-a>")
-- keymap.set("n", "-", "<C-x>")
vim.keymap.set("n", "+", function()
	require("dial.map").manipulate("increment", "normal")
end)
vim.keymap.set("n", "-", function()
	require("dial.map").manipulate("decrement", "normal")
end)
vim.keymap.set("n", "g+", function()
	require("dial.map").manipulate("increment", "gnormal")
end)
vim.keymap.set("n", "g-", function()
	require("dial.map").manipulate("decrement", "gnormal")
end)
vim.keymap.set("v", "+", function()
	require("dial.map").manipulate("increment", "visual")
end)
vim.keymap.set("v", "-", function()
	require("dial.map").manipulate("decrement", "visual")
end)
vim.keymap.set("v", "g+", function()
	require("dial.map").manipulate("increment", "gvisual")
end)
vim.keymap.set("v", "g-", function()
	require("dial.map").manipulate("decrement", "gvisual")
end)

-- Go to definition on new tab
keymap.set("n", "gt", "<cmd>tab split | lua vim.lsp.buf.definition()<cr>")

keymap.set("n", "nx", "<cmd>Trouble diagnostics next<cr>")
keymap.set("n", "Nx", "<cmd>Trouble diagnostics next<cr>")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save file and quit
keymap.set("n", "<Leader>W", ":update<Return>", opts)
keymap.set("n", "<Leader>q", ":quit<Return>", opts)
keymap.set("n", "<Leader>Q", ":qa<Return>", opts)

-- Resize window
keymap.set("n", "<S-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
keymap.set("n", "<S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
keymap.set("n", "<S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })

-- Obsidian Repeat (public not public) keymaps
keymap.set("n", "<leader>og", ":ObsidianRepeatOpenGraph<CR>", opts)
keymap.set("n", "<leader>oc", ":ObsidianRepeatMoveToActiveFile<CR>", opts)
keymap.set("n", "<leader>oo", ":ObsidianRepeatOpen<CR>", opts)
keymap.set("n", "<leader>ol", ":ObsidianRepeatLink<CR>", opts)
keymap.set("n", "<leader>of", ":ObsidianRepeatLinkFolders<CR>", opts)
