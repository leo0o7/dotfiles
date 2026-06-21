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
			vim.lsp.set_log_level("off")

			local ltex_languages = {
				["en-US"] = "en_us",
				["en-GB"] = "en_gb",
				["it-IT"] = "it",
			}
			local ltex_filetypes = {
				bib = "bibtex",
				gitcommit = "gitcommit",
				markdown = "markdown",
				org = "org",
				plaintex = "tex",
				rst = "restructuredtext",
				tex = "latex",
				typst = "typst",
			}
			local ltex_enabled = vim.tbl_values(ltex_filetypes)
			local default_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]

			vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
				local client = vim.lsp.get_client_by_id(ctx.client_id)

				if client and client.name == "ltex_plus" then
					local language = vim.tbl_get(client.config.settings or {}, "ltex", "language")

					if language ~= (vim.g.ltex_language or "en-US") then
						local namespace = vim.lsp.diagnostic.get_namespace(client.id)
						local bufnr = result and result.uri and vim.uri_to_bufnr(result.uri)

						if bufnr then
							vim.diagnostic.reset(namespace, bufnr)
						end

						return
					end
				end

				return default_publish_diagnostics(err, result, ctx, config)
			end

			local function get_ltex_cmd()
				local cmd = vim.fn.exepath("ltex-ls-plus")

				if cmd ~= "" then
					return cmd
				end

				return vim.fn.stdpath("data") .. "/mason/bin/ltex-ls-plus"
			end

			local function get_ltex_language(bufnr)
				return vim.g.ltex_language or "en-US"
			end

			local function client_ltex_language(client)
				return vim.tbl_get(client.config.settings or {}, "ltex", "language")
			end

			local function stop_ltex(bufnr)
				bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr

				for _, client in ipairs(vim.lsp.get_clients({ name = "ltex_plus", bufnr = bufnr })) do
					local ok, namespace = pcall(vim.lsp.diagnostic.get_namespace, client.id)

					if ok then
						vim.diagnostic.reset(namespace, bufnr)
					end

					pcall(vim.lsp.buf_detach_client, bufnr, client.id)
					vim.lsp.stop_client(client.id, false)
				end

				for _, client in ipairs(vim.lsp.get_clients({ name = "ltex_plus" })) do
					vim.lsp.stop_client(client.id, false)
				end

				vim.b[bufnr].ltex_plus_starting = false
			end

			local function start_ltex(bufnr, force)
				bufnr = bufnr or vim.api.nvim_get_current_buf()
				local filetype = vim.bo[bufnr].filetype
				local language_id = ltex_filetypes[filetype]

				if not language_id then
					return
				end

				if not force and vim.b[bufnr].ltex_plus_starting then
					return
				end

				if not force and #vim.lsp.get_clients({ name = "ltex_plus", bufnr = bufnr }) > 0 then
					return
				end

				local language = get_ltex_language(bufnr)
				local spelllang = ltex_languages[language]

				if spelllang then
					vim.bo[bufnr].spelllang = spelllang
				end

				vim.g.ltex_language = language
				vim.b[bufnr].ltex_plus_starting = true

				vim.lsp.start({
					name = "ltex_plus",
					cmd = { get_ltex_cmd() },
					root_dir = vim.fs.root(bufnr, ".git") or vim.fn.getcwd(),
					on_attach = function(client, attached_bufnr)
						if language ~= (vim.g.ltex_language or "en-US") then
							pcall(vim.lsp.buf_detach_client, attached_bufnr, client.id)
							vim.lsp.stop_client(client.id, false)
							return
						end

						vim.b[attached_bufnr].ltex_plus_starting = false
					end,
					get_language_id = function()
						return language_id
					end,
					settings = {
						ltex = {
							language = language,
							enabled = ltex_enabled,
							checkFrequency = "edit",
							completionEnabled = false,
							diagnosticSeverity = "information",
							additionalRules = {
								enablePickyRules = false,
							},
						},
					},
				}, {
					bufnr = bufnr,
					reuse_client = function(client, config)
						return client.name == "ltex_plus"
							and client.config.root_dir == config.root_dir
							and client_ltex_language(client) == language
					end,
				})
			end

			local function set_ltex_language(language)
				local spelllang = ltex_languages[language]
				vim.g.ltex_language = language

				if spelllang then
					vim.opt_local.spelllang = spelllang
				end

				stop_ltex(0)
				vim.diagnostic.reset(nil, 0)
				vim.defer_fn(function()
					start_ltex(0, true)
				end, 1000)
				vim.notify("LTeX language: " .. language .. (spelllang and ", spelllang: " .. spelllang or ""))
			end

			vim.api.nvim_create_user_command("LtexLanguage", function(opts)
				set_ltex_language(opts.args ~= "" and opts.args or "en-US")
			end, {
				nargs = "?",
				complete = function()
					return { "en-US", "en-GB", "it-IT", "auto" }
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
			vim.keymap.set("n", "<leader>clc", "<cmd>LtexCheck<cr>", { desc = "LTeX Check" })

			vim.api.nvim_create_user_command("LtexCheck", function()
				local clients = vim.lsp.get_clients({ name = "ltex_plus", bufnr = 0 })
				local language_id = ltex_filetypes[vim.bo.filetype]

				if #clients == 0 then
					vim.notify("ltex_plus is not attached to this buffer", vim.log.levels.WARN)
					return
				end

				local params = {
					command = "_ltex.checkDocument",
					arguments = {
						{
							uri = vim.uri_from_bufnr(0),
							codeLanguageId = language_id,
							text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"),
						},
					},
				}

				clients[1].request("workspace/executeCommand", params, function(err, result)
					if err then
						vim.notify("LTeX check failed: " .. vim.inspect(err), vim.log.levels.ERROR)
						return
					end

					if result and result.success == false then
						vim.notify(
							"LTeX check failed: " .. (result.errorMessage or "unknown error"),
							vim.log.levels.ERROR
						)
						return
					end

					vim.notify("LTeX check requested")
				end, 0)
			end, {})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = vim.tbl_keys(ltex_filetypes),
				callback = function()
					vim.defer_fn(function()
						start_ltex(0)
					end, 200)
				end,
			})

			vim.api.nvim_create_user_command("LtexStatus", function()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				local diagnostics = vim.diagnostic.get(0, { namespace = nil })
				local client_names = vim.tbl_map(function(client)
					local language = vim.tbl_get(client.config.settings or {}, "ltex", "language")
					return language and (client.name .. "(" .. language .. ")") or client.name
				end, clients)

				vim.notify(table.concat({
					"filetype: " .. vim.bo.filetype,
					"spell: " .. tostring(vim.wo.spell),
					"spelllang: " .. vim.bo.spelllang,
					"wanted ltex language: " .. (vim.g.ltex_language or "en-US"),
					"diagnostics: " .. #diagnostics,
					"lsp clients: " .. (#client_names > 0 and table.concat(client_names, ", ") or "none"),
					"lsp log: " .. vim.lsp.log.get_filename(),
				}, "\n"))
			end, {})
		end,
		opts = {
			inlay_hints = { enabled = false },
			---@type lspconfig.options
			servers = {
				bashls = { filetypes = { "sh", "zsh" } },
				clangd = {},
				jdtls = {},
				cssls = {},
				ltex_plus = { enabled = false },
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
				ltex_plus = function()
					return true -- started manually above to avoid duplicate/default en-US clients
				end,
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
