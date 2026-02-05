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

			transparent.clear_prefix("lualine_transitional_lualine_b")
			transparent.clear_prefix("lualine_c")
			transparent.clear_prefix("lualine_x")
			transparent.clear_prefix("WhichKey")
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
