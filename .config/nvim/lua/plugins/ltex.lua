-- vim.g.vimtex_view_method = "zathura"
-- vim.g.vimtex_view_zathura_use_synctex = 0
-- vim.g.vimtex_view_method = "general"
-- vim.g.vimtex_view_general_viewer = "open"
-- vim.g.vimtex_view_general_options = "-a zathura @pdf"
-- vim.g.vimtex_view_method = "general"
-- vim.g.vimtex_view_general_viewer = "open"
-- vim.g.vimtex_view_general_options = "-a sioyek @pdf"

vim.api.nvim_create_autocmd("User", {
	pattern = "VimtexEventCompileSuccess",
	callback = function()
		local src_dir = vim.fn.expand("%:p:h")
		local name = vim.fn.expand("%:t:r")
		local pdf_out = "/tmp/latexbuild/" .. name .. ".pdf"
		local dest = src_dir .. "/" .. name .. ".pdf"
		vim.fn.system(string.format("cp '%s' '%s'", pdf_out, dest))
	end,
})
vim.g.vimtex_view_method = "sioyek"
vim.g.vimtex_view_sioyek_exe = "/Applications/sioyek.app/Contents/MacOS/sioyek"
vim.g.vimtex_view_forward_search_on_start = 1

return {
	"lervag/vimtex",
	opts = {},
	config = function()
		vim.g.vimtex_compiler_latexmk = {
			out_dir = "/tmp/latexbuild",
		}
	end,
}
