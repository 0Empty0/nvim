return {
	{
		"xiyaowong/transparent.nvim",
		lazy = false,
		config = function()
			local transparent = require("transparent")

			transparent.setup({
				extra_groups = {
					"IndentBlanklineChar",

					"LspFloatWinNormal",
					"Normal",
					"NormalFloat",
					"FloatBorder",
					"SagaBorder",
					"SagaNormal",
				},
			})

			transparent.clear_prefix("Noice")
			transparent.clear_prefix("lualine_transitional_lualine_b")
			transparent.clear_prefix("lualine_c")
			transparent.clear_prefix("lualine_x")
			transparent.clear_prefix("WhichKey")
		end,
	},

	{
		"slugbyte/lackluster.nvim",
		priority = 1000,
		opts = {},
	},

	{
		"wnkz/monoglow.nvim",
		priority = 1000,
		opts = {},
	},

	{
		"bjarneo/aether.nvim",
		branch = "v2",
		name = "aether",
		priority = 1000,
		opts = {
			transparent = true,

			styles = {
				comments = { italic = true },
				keywords = { italic = true },
				sidebars = "transparent",
				floats = "transparent",
			},

			colors = {
				-- Backgrounds
				bg = "#0d0d0d",
				bg_dark = "#0d0d0d",
				bg_highlight = "#8d8d8d", -- Used for selection/active line

				-- Primary Foreground
				fg = "#fdfdfd", -- Default text color
				fg_dark = "#b0b0b0",
				fg_gutter = "#a4a4a4",

				-- Syntax Colors (Mapped from your Vanta Black palette)
				-- To fix the "blue" characters, we map them to grays from your theme
				red = "#a4a4a4", -- Variables, errors
				orange = "#b6b6b6", -- Constants, numbers
				yellow = "#cecece", -- Classes, types
				green = "#8d8d8d", -- Strings
				cyan = "#b0b0b0", -- Operators, punctuation (Prevents blue)
				blue = "#cecece", -- Functions (Prevents blue)
				purple = "#ececec", -- Keywords, tags
				magenta = "#fdfdfd", -- Special characters			},
			},
		},
		config = function(_, opts)
			require("aether").setup(opts)

			require("aether.hotreload").setup()

			-- 1. Fix the selection bar color (the bar that follows your cursor)
			-- Setting it to a dark gray from your Vanta Black palette
			vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { bg = "#262626", bold = true })

			-- 2. Fix the dimmed/hidden path visibility
			-- Mapping them to a lighter gray (#a4a4a4) so they are readable on the selection bar
			local dimmed_fg = "#a4a4a4"
			vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = dimmed_fg })
			vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { fg = dimmed_fg })
			vim.api.nvim_set_hl(0, "SnacksPickerPathIgnored", { fg = dimmed_fg })

			-- 3. Optional: Ensure the active file text is bright white
			vim.api.nvim_set_hl(0, "SnacksPickerFileName", { fg = "#fdfdfd" })
		end,
	},
	{
		"Shatur/neovim-ayu",
		config = function()
			require("ayu").setup({})
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
	},
}
