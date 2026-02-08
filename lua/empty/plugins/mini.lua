return {
	{
		"nvim-mini/mini.extra",
		config = function()
			require("mini.extra").setup()
		end,
	},

	-- Statusline
	{
		"nvim-mini/mini.statusline",
		event = "VeryLazy",
		config = function()
			local statusline = require("mini.statusline")
			local icons = require("mini.icons")

			statusline.setup({
				use_icons = true,
				content = {
					active = function()
						if vim.bo.filetype == "snacks_dashboard" then
							return ""
						end

						local mode, mode_hl = statusline.section_mode({ trunc_width = 0 })
						local git = statusline.section_git({ trunc_width = 40 })
						local diff = statusline.section_diff({ trunc_width = 75 })
						local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
						local filename = statusline.section_filename({ trunc_width = 140 })
						local fileinfo = function()
							local filetype = vim.bo.filetype
							local icon, _ = icons.get("filetype", filetype)

							return string.format("%s %s", icon or "", filetype)
						end
						local progress = function()
							local cur = vim.fn.line(".")
							local total = vim.fn.line("$")
							if total == 0 or cur == 0 then
								return "0%"
							end
							return string.format("%d%%", math.floor((cur / total) * 100)):gsub("%%", "%%%%")
						end
						local location = "%l:%v"

						local get_hl = function(name, attr)
							local hl = vim.api.nvim_get_hl(0, { name = name })
							return hl[attr] and string.format("#%06x", hl[attr]) or nil
						end

						local normal_bg = get_hl("Normal", "bg") or "NONE"
						local mode_bg = get_hl(mode_hl, "bg") or get_hl("StatusLine", "bg") or normal_bg
						local dev_bg = get_hl("MiniStatuslineDevinfo", "bg") or get_hl("StatusLine", "bg") or normal_bg
						local file_bg = get_hl("MiniStatuslineFilename", "bg")
							or get_hl("StatusLine", "bg")
							or normal_bg
						local fileinfo_bg = get_hl("MiniStatuslineFileinfo", "bg")
							or get_hl("StatusLine", "bg")
							or normal_bg

						vim.api.nvim_set_hl(0, "StatusLineToMode", { fg = mode_bg, bg = dev_bg })
						vim.api.nvim_set_hl(0, "StatusLineModeToDev", { fg = mode_bg, bg = dev_bg })
						vim.api.nvim_set_hl(0, "StatusLineDevToFile", { fg = dev_bg, bg = file_bg })
						vim.api.nvim_set_hl(0, "StatusLineFileToNormal", { fg = file_bg, bg = normal_bg })
						vim.api.nvim_set_hl(0, "StatusLineNormalToFileinfo", { fg = dev_bg, bg = file_bg })
						vim.api.nvim_set_hl(0, "StatusLineFileinfoToMode", { fg = mode_bg, bg = fileinfo_bg })
						vim.api.nvim_set_hl(0, "StatusLineModeToEnd", { fg = mode_bg, bg = normal_bg })

						local sections = {
							"%#StatusLineToMode#",
							"%#",
							mode_hl,
							"# ",
							mode,
							" ",
							"%#StatusLineModeToDev#",
							"%#MiniStatuslineDevinfo# ",
							diff,
							" | ",
							git,
							" ",
							diagnostics,
							" ",
							"%#StatusLineDevToFile#",
							"%<",
							"%#MiniStatuslineFilename# ",
							filename,
							" ",
							"%=",
							"%#StatusLineNormalToFileinfo#",
							"%#MiniStatuslineFileinfo# ",
							fileinfo(),
							" ",
							"%#StatusLineFileinfoToMode#",
							"%#",
							mode_hl,
							"# ",
							progress(),
							" ",
							location,
							" ",
							"%#StatusLineModeToEnd#",
						}

						return table.concat(sections)
					end,
				},
			})

			-- Disable statusline on dashboard
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "snacks_dashboard",
				callback = function()
					vim.opt_local.statusline = ""
				end,
			})
		end,
	},

	{
		"nvim-mini/mini-git",
		version = "*",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("mini.git").setup()

			local format_summary = function(data)
				local summary = vim.b[data.buf].minigit_summary
				vim.b[data.buf].minigit_summary_string = summary.head_name or ""
			end

			local au_opts = { pattern = "MiniGitUpdated", callback = format_summary }
			vim.api.nvim_create_autocmd("User", au_opts)
		end,
	},

	-- Git diff signs
	{
		"nvim-mini/mini.diff",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("mini.diff").setup({
				view = {
					style = "sign",
					signs = {
						add = "▎",
						change = "▎",
						delete = "▎",
					},
				},
			})

			-- Keymaps
			vim.keymap.set("n", "]h", function()
				require("mini.diff").goto_hunk("next")
			end, { desc = "Next Hunk" })
			vim.keymap.set("n", "[h", function()
				require("mini.diff").goto_hunk("prev")
			end, { desc = "Prev Hunk" })
			vim.keymap.set("n", "<leader>ghs", function()
				require("mini.diff").do_hunk("stage")
			end, { desc = "Stage Hunk" })
			vim.keymap.set("n", "<leader>ghr", function()
				require("mini.diff").do_hunk("reset")
			end, { desc = "Reset Hunk" })
			vim.keymap.set("n", "<leader>ghp", function()
				require("mini.diff").show_hunk()
			end, { desc = "Preview Hunk" })
			vim.keymap.set("n", "<leader>ghS", function()
				require("mini.diff").do_hunks("stage", vim.api.nvim_buf_get_number(0))
			end, { desc = "Stage Buffer" })
			vim.keymap.set("n", "<leader>ghu", function()
				require("mini.diff").do_hunk("undo")
			end, { desc = "Undo Stage Hunk" })

			local format_summary = function(data)
				local summary = vim.b[data.buf].minidiff_summary
				local t = {}
				if summary.add > 0 then
					table.insert(t, "+" .. summary.add)
				end
				if summary.change > 0 then
					table.insert(t, "~" .. summary.change)
				end
				if summary.delete > 0 then
					table.insert(t, "-" .. summary.delete)
				end
				vim.b[data.buf].minidiff_summary_string = table.concat(t, " ")
			end
			local au_opts = { pattern = "MiniDiffUpdated", callback = format_summary }
			vim.api.nvim_create_autocmd("User", au_opts)
		end,
	},

	-- Icons
	{
		"nvim-mini/mini.icons",
		lazy = true,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
		},
		init = function()
			if package.preload["nvim-web-devicons"] == nil then
				rawset(package.preload, "nvim-web-devicons", function()
					require("mini.icons").mock_nvim_web_devicons()
					return package.loaded["nvim-web-devicons"]
				end)
			end
		end,
		config = function()
			require("mini.icons").setup()
			require("mini.icons").tweak_lsp_kind()
		end,
	},

	-- Animations
	{
		"nvim-mini/mini.animate",
		event = "VeryLazy",
		cond = vim.g.neovide == nil,
		opts = function(_, opts)
			-- don't use animate when scrolling with the mouse
			local mouse_scrolled = false
			for _, scroll in ipairs({ "Up", "Down" }) do
				local key = "<ScrollWheel" .. scroll .. ">"
				vim.keymap.set({ "", "i" }, key, function()
					mouse_scrolled = true
					return key
				end, { expr = true })
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "grug-far",
				callback = function()
					vim.b.minianimate_disable = true
				end,
			})

			-- schedule setting the mapping to override the default mapping from `keymaps.lua`
			-- seems `keymaps.lua` is the last event to execute on `VeryLazy` and it overwrites it
			vim.schedule(function()
				Snacks.toggle({
					name = "Mini Animate",
					get = function()
						return not vim.g.minianimate_disable
					end,
					set = function(state)
						vim.g.minianimate_disable = not state
					end,
				}):map("<leader>ua")
			end)

			local animate = require("mini.animate")
			return vim.tbl_deep_extend("force", opts, {
				resize = {
					timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
				},
				scroll = {
					timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
					subscroll = animate.gen_subscroll.equal({
						predicate = function(total_scroll)
							if mouse_scrolled then
								mouse_scrolled = false
								return false
							end
							return total_scroll > 1
						end,
					}),
				},
			})
		end,
		config = function()
			require("mini.animate").setup({
				scroll = { enable = false },
			})
		end,
	},

	-- Auto pairs
	-- Automatically inserts a matching closing character
	-- when you type an opening character like `"`, `[`, or `(`.
	{
		"nvim-mini/mini.pairs",
		event = "VeryLazy",
		opts = {
			modes = { insert = true, command = true, terminal = false },
			-- skip autopair when next character is one of these
			skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
			-- skip autopair when the cursor is inside these treesitter nodes
			skip_ts = { "string" },
			-- skip autopair when next character is closing pair
			-- and there are more closing pairs than opening pairs
			skip_unbalanced = true,
			-- better deal with markdown code blocks
			markdown = true,
		},
		config = function(_, opts)
			require("mini.pairs").setup(opts)
		end,
	},

	-- Extends the a & i text objects, this adds the ability to select
	-- arguments, function calls, text within quotes and brackets, and to
	-- repeat those selections to select an outer text object.
	{
		"nvim-mini/mini.ai",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			local extra = require("mini.extra")
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({ -- code block
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
					d = { "%f[%d]%d+" }, -- digits
					e = { -- Word with case
						{
							"%u[%l%d]+%f[^%l%d]",
							"%f[%S][%l%d]+%f[^%l%d]",
							"%f[%P][%l%d]+%f[^%l%d]",
							"^[%l%d]+%f[^%l%d]",
						},
						"^().*()$",
					},
					g = extra.gen_ai_spec.buffer, -- buffer
					u = ai.gen_spec.function_call(), -- u for "Usage"
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
				},
			}
		end,
		config = function(_, opts)
			require("mini.ai").setup(opts)
			vim.schedule(function()
				local objects = {
					{ " ", desc = "whitespace" },
					{ '"', desc = '" string' },
					{ "'", desc = "' string" },
					{ "(", desc = "() block" },
					{ ")", desc = "() block with ws" },
					{ "<", desc = "<> block" },
					{ ">", desc = "<> block with ws" },
					{ "?", desc = "user prompt" },
					{ "U", desc = "use/call without dot" },
					{ "[", desc = "[] block" },
					{ "]", desc = "[] block with ws" },
					{ "_", desc = "underscore" },
					{ "`", desc = "` string" },
					{ "a", desc = "argument" },
					{ "b", desc = ")]} block" },
					{ "c", desc = "class" },
					{ "d", desc = "digit(s)" },
					{ "e", desc = "CamelCase / snake_case" },
					{ "f", desc = "function" },
					{ "g", desc = "entire file" },
					{ "i", desc = "indent" },
					{ "o", desc = "block, conditional, loop" },
					{ "q", desc = "quote `\"'" },
					{ "t", desc = "tag" },
					{ "u", desc = "use/call" },
					{ "{", desc = "{} block" },
					{ "}", desc = "{} with ws" },
				}

				---@type wk.Spec[]
				local ret = { mode = { "o", "x" } }
				---@type table<string, string>
				local mappings = vim.tbl_extend("force", {}, {
					around = "a",
					inside = "i",
					around_next = "an",
					inside_next = "in",
					around_last = "al",
					inside_last = "il",
				}, opts.mappings or {})
				mappings.goto_left = nil
				mappings.goto_right = nil

				for name, prefix in pairs(mappings) do
					name = name:gsub("^around_", ""):gsub("^inside_", "")
					ret[#ret + 1] = { prefix, group = name }
					for _, obj in ipairs(objects) do
						local desc = obj.desc
						if prefix:sub(1, 1) == "i" then
							desc = desc:gsub(" with ws", "")
						end
						ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
					end
				end
				require("which-key").add(ret, { notify = false })
			end)
		end,
	},

	{
		"nvim-mini/mini.operators",
		config = function()
			require("mini.operators").setup()
		end,
	},

	{
		"nvim-mini/mini.comment",
		event = "VeryLazy",
		dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
		opts = {
			options = {
				custom_commentstring = function()
					return require("ts_context_commentstring.internal").calculate_commentstring()
						or vim.bo.commentstring
				end,
			},
		},
		config = function()
			require("mini.comment").setup()
		end,
	},

	{
		"nvim-mini/mini.surround",
		keys = function(_, keys)
			local mappings = {
				{ "gsa", desc = "Add Surrounding", mode = { "n", "x" } },
				{ "gsd", desc = "Delete Surrounding" },
				{ "gsf", desc = "Find Right Surrounding" },
				{ "gsF", desc = "Find Left Surrounding" },
				{ "gsh", desc = "Highlight Surrounding" },
				{ "gsr", desc = "Replace Surrounding" },
				{ "gsn", desc = "Update `MiniSurround.config.n_lines`" },
			}
			mappings = vim.tbl_filter(function(m)
				return m[1] and #m[1] > 0
			end, mappings)
			return vim.list_extend(mappings, keys)
		end,
		opts = {
			mappings = {
				add = "gsa", -- Add surrounding in Normal and Visual modes
				delete = "gsd", -- Delete surrounding
				find = "gsf", -- Find surrounding (to the right)
				find_left = "gsF", -- Find surrounding (to the left)
				highlight = "gsh", -- Highlight surrounding
				replace = "gsr", -- Replace surrounding
				update_n_lines = "gsn", -- Update `n_lines`
			},
		},
		config = function(_, opts)
			require("mini.surround").setup(opts)
		end,
	},
}
