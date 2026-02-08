local function term_nav(dir)
	---@param self snacks.terminal
	return function(self)
		return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
			vim.cmd.wincmd(dir)
		end)
	end
end

return {
	{
		"MaximilianLloyd/ascii.nvim",
		lazy = false,
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		dependencies = { "MaximilianLloyd/ascii.nvim" },
		opts = function()
			local ascii = require("ascii")
			local header = table.concat(ascii.art.text.neovim.bloody, "\n")

			---@type snacks.Config
			return {
				bigfile = { enabled = true },
				quickfile = { enabled = true },
				dim = {
					enabled = true,
					scope = {
						min_size = 10,
					},
				},
				input = { enabled = true },
				notifier = { enabled = true },
				scope = { enabled = true },
				statuscolumn = { enabled = true },
				words = { enabled = true },
				image = { enabled = true },
				indent = {
					enabled = true,
					indent = {
						only_scope = true,
					},
					chunk = {
						enabled = true,
					},
				},
				explorer = { enabled = true },
				picker = {
					enabled = true,
					win = {
						border = "rounded",
						input = {
							keys = {
								["<localleader>o"] = { "opencode_send", mode = { "n", "i" } },
							},
						},
					},
					sources = {
						explorer = {
							hidden = true,
							ignored = true,
							exclude = {
								".output",
								".git",
								".svelte-kit",
								"node_modules",
								"dist",
								"build",
								".next",
								".turbo",
								".cache",
								".venv",
								"target",
								".DS_Store",
							},
							auto_close = true,
							jump = { close = true },
						},
						files = {
							hidden = true,
							ignored = true,
							exclude = {
								".output",
								".git",
								".svelte-kit",
								"node_modules",
								"dist",
								"build",
								".next",
								".turbo",
								".cache",
								".venv",
								"target",
								".DS_Store",
							},
						},
					},
					actions = {
						opencode_send = function(picker)
							local selected = picker:selected({ fallback = true })
							if selected and #selected > 0 then
								local files = {}
								for _, item in ipairs(selected) do
									if item.file then
										table.insert(files, item.file)
									end
								end
								picker:close()

								require("opencode.core").open({
									new_session = false,
									focus = "input",
									start_insert = true,
								})

								local context = require("opencode.context")
								for _, file in ipairs(files) do
									context.add_file(file)
								end
							end
						end,
					},
				},
				gh = { enabled = true },
				gitbrowse = { enabled = true },
				lazygit = {
					enabled = true,
					win = { border = "rounded" },
				},
				terminal = {
					enabled = true,
					win = {
						position = "float",
						width = 0.8,
						height = 0.8,
						border = "rounded",
						keys = {
							nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
							nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
							nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
							nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
						},
					},
				},
				zen = { enabled = true },
				dashboard = {
					enabled = true,
					preset = {
						header = header,
						---@type snacks.dashboard.Item[]
						keys = {
							{
								icon = " ",
								key = "f",
								desc = "Find File",
								action = ":lua Snacks.dashboard.pick('files')",
							},
							{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
							{
								icon = " ",
								key = "g",
								desc = "Find Text",
								action = ":lua Snacks.dashboard.pick('live_grep')",
							},
							{
								icon = " ",
								key = "r",
								desc = "Recent Files",
								action = ":lua Snacks.dashboard.pick('oldfiles')",
							},
							{
								icon = " ",
								key = "c",
								desc = "Config",
								action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
							},
							{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
							{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
							{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
						},
					},
				},
			}
		end,
		keys = {
			{
				"<leader>n",
				function()
					Snacks.picker.notifications()
				end,
				desc = "Notification History",
			},
			{
				"<leader>un",
				function()
					Snacks.notifier.hide()
				end,
				desc = "Dismiss All Notifications",
			},

			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>S",
				function()
					Snacks.scratch.select()
				end,
				desc = "Select Scratch Buffer",
			},
			{
				"<leader>dps",
				function()
					Snacks.profiler.scratch()
				end,
				desc = "Profiler Scratch Buffer",
			},

			{
				"<leader>e",
				function()
					Snacks.explorer.open({
						layout = {
							hidden = { "preview" },
							layout = {
								backdrop = false,
								width = 0.75,
								min_width = 80,
								height = 0.75,
								border = "rounded",
								box = "vertical",
								{
									win = "input",
									height = 1,
									border = true,
									title = "{title} {live} {flags}",
									title_pos = "center",
								},
								{ win = "list", border = "hpad" },
								{ win = "preview", title = "{preview}", border = true },
							},
						},
					})
				end,
				desc = "Explorer",
			},
			{
				"<leader>hh",
				function()
					Snacks.picker.marks()
				end,
				desc = "Marks",
			},
			{
				"<leader>uh",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo History",
			},
			{
				"<leader>ud",
				function()
					Snacks.toggle.dim():toggle()
				end,
				desc = "Toggle Dim",
			},
			{
				"<leader>ut",
				function()
					Snacks.picker.colorschemes()
				end,
				desc = "Theme Picker",
			},
		},
		config = function(_, opts)
			require("snacks").setup(opts)

			Snacks.dim.enable(opts)
		end,
	},
}
