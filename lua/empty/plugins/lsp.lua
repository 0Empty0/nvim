local mason_registry = require("mason-registry")

return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"b0o/schemastore.nvim",
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"L3MON4D3/LuaSnip",
			"j-hui/fidget.nvim",
			"saghen/blink.cmp",
			"folke/snacks.nvim",
		},
		opts = {
			servers = {
				astro = {},
				clangd = {
					keys = {
						{ "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
					},
					root_markers = {
						"compile_commands.json",
						"compile_flags.txt",
						"configure.ac", -- AutoTools
						"Makefile",
						"configure.ac",
						"configure.in",
						"config.h.in",
						"meson.build",
						"meson_options.txt",
						"build.ninja",
						".git",
					},
					capabilities = {
						offsetEncoding = { "utf-16" },
					},
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
					init_options = {
						usePlaceholders = true,
						completeUnimported = true,
						clangdFileStatus = true,
					},
				},
				neocmake = {},
				dockerls = {},
				docker_compose_language_service = {},
				fsautocomplete = {},
				omnisharp = {
					handlers = {
						["textDocument/definition"] = function(...)
							return require("omnisharp_extended").handler(...)
						end,
					},
					keys = {
						{
							"gd",
							function()
								require("omnisharp_extended").lsp_definitions()
							end,
							desc = "Goto Definition",
						},
					},
					enable_roslyn_analyzers = true,
					organize_imports_on_format = true,
					enable_import_completion = true,
				},
				gopls = {
					settings = {
						gopls = {
							gofumpt = true,
							codelenses = {
								gc_details = false,
								generate = true,
								regenerate_cgo = true,
								run_govulncheck = true,
								test = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
							analyses = {
								nilness = true,
								unusedparams = true,
								unusedwrite = true,
								useany = true,
							},
							usePlaceholders = true,
							completeUnimported = true,
							staticcheck = true,
							directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
							semanticTokens = true,
						},
					},
				},
				jsonls = {
					-- lazy-load schemastore when needed
					before_init = function(_, new_config)
						new_config.settings.json.schemas = new_config.settings.json.schemas or {}
						vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
					end,
					settings = {
						json = {
							format = {
								enable = true,
							},
							validate = { enable = true },
						},
					},
				},
				marksman = {},
				prismals = {},
				basedpyright = {},
				ruff = {
					cmd_env = { RUFF_TRACE = "messages" },
					init_options = {
						settings = {
							logLevel = "error",
						},
					},
					keys = {
						{
							"<leader>co",
							function()
								vim.lsp.buf.code_action({
									apply = true,
									context = {
										only = { action = "source.organizeImports" },
										diagnostics = {},
									},
								})
							end,
							desc = "Organize Imports",
						},
					},
				},
				bacon_ls = {},
				rust_analyzer = { enabled = false },
				solidity_ls = {},
				tailwindcss = {
					-- exclude a filetype from the default_config
					filetypes_exclude = { "markdown" },
					-- add additional filetypes to the default_config
					filetypes_include = {},
					-- to fully override the default_config, change the below
					-- filetypes = {}

					-- additional settings for the server, e.g:
					-- tailwindCSS = { includeLanguages = { someLang = "html" } }
					-- can be addeded to the settings table and will be merged with
					-- this defaults for Phoenix projects
					settings = {
						tailwindCSS = {
							includeLanguages = {
								elixir = "html-eex",
								eelixir = "html-eex",
								heex = "html-eex",
							},
						},
					},
				},
				taplo = {},
				vtsls = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
						"vue",
					},
					settings = {
						complete_function_calls = true,
						vtsls = {
							enableMoveToFileCodeAction = true,
							autoUseWorkspaceTsdk = true,
							experimental = {
								maxInlayHintLength = 30,
								completion = {
									enableServerSideFuzzyMatch = true,
								},
							},
							tsserver = {
								globalPlugins = {
									{
										name = "@vue/typescript-plugin",
										location = vim.fn.expand(
											"$MASON/packages/vue-language-server/node_modules/@vue/language-server"
										),
										languages = { "vue" },
										configNamespace = "typescript",
										enableForWorkspaceTypeScriptVersions = true,
									},
									{
										name = "typescript-svelte-plugin",
										location = vim.fn.expand(
											"$MASON/packages/svelte-language-server/node_modules/typescript-svelte-plugin"
										),
										enableForWorkspaceTypeScriptVersions = true,
									},
									{
										name = "@astrojs/ts-plugin",
										location = vim.fn.expand(
											"$MASON/packages/astro-language-server/node_modules/@astrojs/ts-plugin"
										),
										enableForWorkspaceTypeScriptVersions = true,
									},
								},
							},
						},
						typescript = {
							updateImportsOnFileMove = { enabled = "always" },
							suggest = {
								completeFunctionCalls = true,
							},
							inlayHints = {
								enumMemberValues = { enabled = true },
								functionLikeReturnTypes = { enabled = true },
								parameterNames = { enabled = "literals" },
								parameterTypes = { enabled = true },
								propertyDeclarationTypes = { enabled = true },
								variableTypes = { enabled = false },
							},
						},
					},
					keys = {
						{
							"gD",
							function()
								local win = vim.api.nvim_get_current_win()
								local params = vim.lsp.util.make_position_params(win, "utf-16")
								LazyVim.lsp.execute({
									command = "typescript.goToSourceDefinition",
									arguments = { params.textDocument.uri, params.position },
									open = true,
								})
							end,
							desc = "Goto Source Definition",
						},
						{
							"gR",
							function()
								LazyVim.lsp.execute({
									command = "typescript.findAllFileReferences",
									arguments = { vim.uri_from_bufnr(0) },
									open = true,
								})
							end,
							desc = "File References",
						},
						{
							"<leader>co",
							function()
								vim.lsp.buf.code_action({
									apply = true,
									context = {
										only = { action = "source.organizeImports" },
										diagnostics = {},
									},
								})
							end,
							desc = "Organize Imports",
						},
						{
							"<leader>cM",
							function()
								vim.lsp.buf.code_action({
									apply = true,
									context = {
										only = { action = "source.addMissingImports.ts" },
										diagnostics = {},
									},
								})
							end,
							desc = "Add missing imports",
						},
						{
							"<leader>cu",
							function()
								vim.lsp.buf.code_action({
									apply = true,
									context = {
										only = { action = "source.removeUnused.ts" },
										diagnostics = {},
									},
								})
							end,
							desc = "Remove unused imports",
						},
						{
							"<leader>cD",
							function()
								vim.lsp.buf.code_action({
									apply = true,
									context = {
										only = { action = "source.fixAll.ts" },
										diagnostics = {},
									},
								})
							end,
							desc = "Fix all diagnostics",
						},
					},
				},
				vue_ls = {},
				yamlls = {
					-- Have to add this for yamlls to understand that we support line folding
					capabilities = {
						textDocument = {
							foldingRange = {
								dynamicRegistration = false,
								lineFoldingOnly = true,
							},
						},
					},
					-- lazy-load schemastore when needed
					before_init = function(_, new_config)
						new_config.settings.yaml.schemas = vim.tbl_deep_extend(
							"force",
							new_config.settings.yaml.schemas or {},
							require("schemastore").yaml.schemas()
						)
					end,
					settings = {
						redhat = { telemetry = { enabled = false } },
						yaml = {
							keyOrdering = false,
							format = {
								enable = true,
							},
							validate = true,
							schemaStore = {
								-- Must disable built-in schemaStore support to use
								-- schemas from SchemaStore.nvim plugin
								enable = false,
								-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
								url = "",
							},
						},
					},
				},
				zls = {},
			},
			setup = {
				gopls = function(_, opts)
					-- workaround for gopls not supporting semanticTokensProvider
					-- https://github.com/golang/go/issues/54531#issuecomment-1464982242
					Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
						if not client.server_capabilities.semanticTokensProvider then
							local semantic = client.config.capabilities.textDocument.semanticTokens
							client.server_capabilities.semanticTokensProvider = {
								full = true,
								legend = {
									tokenTypes = semantic.tokenTypes,
									tokenModifiers = semantic.tokenModifiers,
								},
								range = true,
							}
						end
					end)
					-- end workaround
				end,
				ruff = function()
					Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
						-- Disable hover in favor of Pyright
						client.server_capabilities.hoverProvider = false
					end)
				end,
				tailwindcss = function(_, opts)
					opts.filetypes = opts.filetypes or {}

					-- Add default filetypes
					vim.list_extend(opts.filetypes, vim.lsp.config.tailwindcss.filetypes)

					-- Remove excluded filetypes
					--- @param ft string
					opts.filetypes = vim.tbl_filter(function(ft)
						return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
					end, opts.filetypes)

					-- Add additional filetypes
					vim.list_extend(opts.filetypes, opts.filetypes_include or {})
				end,
				vtsls = function(_, opts)
					if vim.lsp.config.denols and vim.lsp.config.vtsls then
						---@param server string
						local resolve = function(server)
							local markers, root_dir =
								vim.lsp.config[server].root_markers, vim.lsp.config[server].root_dir
							vim.lsp.config(server, {
								root_dir = function(bufnr, on_dir)
									local is_deno = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" }) ~= nil
									if is_deno == (server == "denols") then
										if root_dir then
											return root_dir(bufnr, on_dir)
										elseif type(markers) == "table" then
											local root = vim.fs.root(bufnr, markers)
											return root and on_dir(root)
										end
									end
								end,
							})
						end
						resolve("denols")
						resolve("vtsls")
					end

					Snacks.util.lsp.on({ name = "vtsls" }, function(buffer, client)
						client.commands["_typescript.moveToFileRefactoring"] = function(command, ctx)
							---@type string, string, lsp.Range
							local action, uri, range = unpack(command.arguments)

							local function move(newf)
								client:request("workspace/executeCommand", {
									command = command.command,
									arguments = { action, uri, range, newf },
								})
							end

							local fname = vim.uri_to_fname(uri)
							client:request("workspace/executeCommand", {
								command = "typescript.tsserverRequest",
								arguments = {
									"getMoveToRefactoringFileSuggestions",
									{
										file = fname,
										startLine = range.start.line + 1,
										startOffset = range.start.character + 1,
										endLine = range["end"].line + 1,
										endOffset = range["end"].character + 1,
									},
								},
							}, function(_, result)
								---@type string[]
								local files = result.body.files
								table.insert(files, 1, "Enter new path...")
								vim.ui.select(files, {
									prompt = "Select move destination:",
									format_item = function(f)
										return vim.fn.fnamemodify(f, ":~:.")
									end,
								}, function(f)
									if f and f:find("^Enter new path") then
										vim.ui.input({
											prompt = "Enter move destination:",
											default = vim.fn.fnamemodify(fname, ":h") .. "/",
											completion = "file",
										}, function(newf)
											return newf and move(newf)
										end)
									elseif f then
										move(f)
									end
								end)
							end)
						end
					end)
					-- copy typescript settings to javascript
					opts.settings.javascript =
						vim.tbl_deep_extend("force", {}, opts.settings.typescript, opts.settings.javascript or {})
				end,
			},
		},
		config = function(_, opts)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			if ok_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			local function on_attach(_, bufnr)
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
				end

				map("n", "gd", function()
					Snacks.picker.lsp_definitions()
				end, "LSP: Go to definition")
				map("n", "gD", function()
					Snacks.picker.lsp_declarations()
				end, "LSP: Go to declaration")
				map("n", "gI", function()
					Snacks.picker.lsp_implementations()
				end, "LSP: Go to implementation")
				map("n", "gr", function()
					Snacks.picker.lsp_references()
				end, "LSP: References")
				map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
				map({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature help")
				map("n", "<leader>cr", vim.lsp.buf.rename, "LSP: Rename")
				map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")
			end

			local function setup_server(server, server_opts)
				if server_opts == false or (type(server_opts) == "table" and server_opts.enabled == false) then
					return
				end

				server_opts = server_opts == true and {} or server_opts or {}

				if opts.setup and type(opts.setup[server]) == "function" then
					local skip = opts.setup[server](server, server_opts)
					if skip then
						return
					end
				end

				server_opts.capabilities =
					vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})

				local user_attach = server_opts.on_attach
				server_opts.on_attach = function(client, bufnr)
					if user_attach then
						user_attach(client, bufnr)
					end
					on_attach(client, bufnr)
				end

				vim.lsp.config(server, server_opts)
				vim.lsp.enable(server)
			end

			for server, server_opts in pairs(opts.servers or {}) do
				setup_server(server, server_opts)
			end

			local ok_mason, mason_lspconfig = pcall(require, "mason-lspconfig")
			if ok_mason then
				local ensure = {}
				for server, server_opts in pairs(opts.servers or {}) do
					if server_opts ~= false and (type(server_opts) ~= "table" or server_opts.enabled ~= false) then
						if not (type(server_opts) == "table" and server_opts.mason == false) then
							table.insert(ensure, server)
						end
					end
				end
				mason_lspconfig.setup({
					ensure_installed = ensure,
					automatic_enable = false,
				})
			end
		end,
	},
}
