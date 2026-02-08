return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "VeryLazy",
	priority = 1000,
	config = function()
		require("tiny-inline-diagnostic").setup({
			preset = "nonerdfont", -- Can be: "modern", "classic", "minimal", "powerline", "ghost"

			-- Customize appearance
			hi = {
				error = "DiagnosticError",
				warn = "DiagnosticWarn",
				info = "DiagnosticInfo",
				hint = "DiagnosticHint",
				arrow = "NonText",
				background = "CursorLine",
				mixing_color = "None",
			},

			-- Options
			options = {
				-- Show diagnostics only on the current line
				show_source = true,
				-- Use icons
				use_icons = true,
				-- Throttle diagnostic updates (in milliseconds)
				throttle = 0,
				-- Enable soft wrap for long diagnostics
				softwrap = 30,
				-- Show diagnostic message on multiple lines
				multiple_lines = true,
				-- Show all diagnostics on the cursor line
				show_all_diags_on_cursorline = false,
				-- Enable diagnostic signs
				enable_on_insert = false,
			},
		})

		-- Disable default virtual text diagnostics
		vim.diagnostic.config({ virtual_text = false })
	end,
}
