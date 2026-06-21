return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			render_modes = { "n", "c" },
			code = {
				sign = true,
				width = "full",
			},
			heading = {
				sign = true,
				icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
			},
			checkbox = {
				enabled = true,
				bullet = true,
			},
			completions = { blink = { enabled = true } },
		},
		ft = { "markdown", "norg", "rmd", "org" },
		config = function(_, opts)
			require("render-markdown").setup(opts)
			Snacks.toggle({
				name = "Render Markdown",
				get = require("render-markdown").get,
				set = require("render-markdown").set,
			}):map("<leader>um")
		end,
	},
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = function(_, opts)
			opts.formatters_by_ft["markdown"] = { "prettier", "markdownlint-cli2" }
			opts.formatters_by_ft["markdown.mdx"] = { "prettier", "markdownlint-cli2" }
		end,
	},
	{ "not-manu/filemention.nvim", event = "InsertEnter", opts = {} },
}
