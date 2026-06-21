return {
	-- tools
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, {
				"luacheck",
				"shellcheck",
				"shfmt",
				"jdtls",
				"tailwindcss-language-server",
				"typescript-language-server",
				"rust-analyzer",
				"codelldb",
				"css-lsp",
				"ltex-ls-plus",
				"java-debug-adapter",
				"java-test",
			})
		end,
	},
	-- lsp servers
	{
		"neovim/nvim-lspconfig",
		init = function()
			local ltex_languages = {
				["en-US"] = "en_us",
				["en-GB"] = "en_gb",
				["it-IT"] = "it",
			}

			local function set_ltex_language(language)
				local spelllang = ltex_languages[language]

				if not spelllang then
					vim.notify("Unsupported LTeX language: " .. language, vim.log.levels.ERROR)
					return
				end

				vim.g.ltex_language = language
				vim.opt_local.spelllang = spelllang

				vim.lsp.enable("ltex_plus", false)
				vim.lsp.config("ltex_plus", {
					settings = {
						ltex = {
							language = language,
							checkFrequency = "edit",
							completionEnabled = false,
							diagnosticSeverity = "information",
							additionalRules = {
								enablePickyRules = false,
							},
						},
					},
				})
				vim.diagnostic.reset(nil, 0)
				vim.lsp.enable("ltex_plus", true)
				vim.notify("LTeX language: " .. language .. ", spelllang: " .. spelllang)
			end

			vim.api.nvim_create_user_command("LtexLanguage", function(opts)
				set_ltex_language(opts.args ~= "" and opts.args or "en-US")
			end, {
				nargs = "?",
				complete = function()
					return { "en-US", "en-GB", "it-IT" }
				end,
			})

			vim.api.nvim_create_user_command("LtexEnglish", function()
				vim.cmd("LtexLanguage en-US")
			end, {})

			vim.api.nvim_create_user_command("LtexItalian", function()
				vim.cmd("LtexLanguage it-IT")
			end, {})

			vim.keymap.set("n", "<leader>clE", "<cmd>LtexLanguage en-US<cr>", { desc = "LTeX English" })
			vim.keymap.set("n", "<leader>clI", "<cmd>LtexLanguage it-IT<cr>", { desc = "LTeX Italian" })
		end,
		opts = {
			inlay_hints = { enabled = false },
			---@type lspconfig.options
			servers = {
				bashls = { filetypes = { "sh", "zsh" } },
				clangd = {},
				jdtls = {},
				cssls = {},
				ltex_plus = {
					cmd = { "ltex-ls-plus" },
					settings = {
						ltex = {
							language = vim.g.ltex_language or "en-US",
							checkFrequency = "edit",
							completionEnabled = false,
							diagnosticSeverity = "information",
							additionalRules = {
								enablePickyRules = false,
							},
						},
					},
				},
				tinymist = {
					keys = {
						{
							"<leader>cP",
							function()
								local buf_name = vim.api.nvim_buf_get_name(0)
								local file_name = vim.fn.fnamemodify(buf_name, ":t")
								LazyVim.lsp.execute({
									title = "Pin Main",
									filter = "tinymist",
									command = "tinymist.pinMain",
									arguments = { buf_name },
								})
								LazyVim.info("Tinymist: Pinned " .. file_name)
							end,
							desc = "Pin main file",
						},
					},
					single_file_support = true,
					settings = {
						formatterMode = "typstyle",
						-- PDF export for Sioyek
						-- exportPdf = "onSave",
						exportPdf = "onType",
						outputPath = "$root/pdfs/$dir/$name",
					},
				},
				tailwindcss = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
				},
				ts_ls = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
					single_file_support = false,
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
				},
				html = {},
				lua_ls = {
					-- enabled = false,
					single_file_support = true,
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								workspaceWord = true,
								callSnippet = "Both",
							},
							misc = {
								parameters = {
									-- "--log-level=trace",
								},
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
							doc = {
								privateName = { "^_" },
							},
							type = {
								castNumberToInteger = true,
							},
							diagnostics = {
								globals = { "vim" },
								disable = { "incomplete-signature-doc", "trailing-space" },
								-- enable = false,
								groupSeverity = {
									strong = "Warning",
									strict = "Warning",
								},
								groupFileStatus = {
									["ambiguity"] = "Opened",
									["await"] = "Opened",
									["codestyle"] = "None",
									["duplicate"] = "Opened",
									["global"] = "Opened",
									["luadoc"] = "Opened",
									["redefined"] = "Opened",
									["strict"] = "Opened",
									["strong"] = "Opened",
									["type-check"] = "Opened",
									["unbalanced"] = "Opened",
									["unused"] = "Opened",
								},
								unusedLocalExclude = { "_*" },
							},
							format = {
								enable = false,
								defaultConfig = {
									indent_style = "space",
									indent_size = "2",
									continuation_indent_size = "2",
								},
							},
						},
					},
				},
			},
			setup = {
				rust_analyzer = function()
					return true -- use rustaceanvim
				end,
				jdtls = function()
					return true -- avoid duplicate servers
				end,
			},
		},
	},
}
