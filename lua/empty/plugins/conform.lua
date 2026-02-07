return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPost", "BufNewFile" },
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cF",
				function()
					require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
				end,
				mode = { "n", "x" },
				desc = "Format Injected Langs",
			},
		},
		---@type conform.setupOpts
		opts = {
			default_format_opts = {
				timeout_ms = 3000,
				async = false,
				quiet = false,
				lsp_format = "fallback",
			},
			formatters_by_ft = {
				lua = { "stylua" },
				fish = { "fish_indent" },
				sh = { "shfmt" },
				svelte = { "prettier" },
				sql = { "sqlfluff" },
				mysql = { "sqlfluff" },
				plsql = { "sqlfluff" },
				solidity = { "forge_fmt" },
				["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
				["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
				go = { "goimports", "gofumpt" },
				cs = { "csharpier" },
				fsharp = { "fantomas" },
				javascript = { "biome-check" },
				javascriptreact = { "biome-check" },
				typescript = { "biome-check" },
				typescriptreact = { "biome-check" },
				json = { "biome-check" },
				jsonc = { "biome-check" },
				css = { "biome" },
				vue = { "biome-check" },
				astro = { "biome-check" },
				python = { "black" },
			},
			formatters = {
				injected = { options = { ignore_errors = true } },
				qlfluff = {
					args = { "format", "--dialect=ansi", "-" },
				},
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
					end,
				},
				["markdownlint-cli2"] = {
					condition = function(_, ctx)
						local diag = vim.tbl_filter(function(d)
							return d.source == "markdownlint"
						end, vim.diagnostic.get(ctx.buf))
						return #diag > 0
					end,
				},
			},
		},
		config = function(_, opts)
			require("conform").setup(opts)
			require("empty.util.format").setup()
		end,
	},
}
