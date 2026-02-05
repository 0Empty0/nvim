return {
  'sudo-tee/opencode.nvim',
  lazy = false,
  cond = function()
    return vim.fn.executable('opencode') == 1
  end,
  config = function()
    require('opencode').setup({
      preferred_picker = 'snacks',
      preferred_completion = 'blink',
      quick_chat = {
        default_model = "opencode/gpt-5-nano", -- works better with a fast model like gpt-4.1
      },
      ui = {
        picker = {
          ---@module "snacks"
          ---@type snacks.picker.layout.Config | nil
          snacks_layout = {
            layout = { border = "none", box = "vertical" }
          },
        },
      },
    })
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        anti_conceal = { enabled = false },
        file_types = { 'markdown', 'opencode_output' },
      },
      ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
    },
    'saghen/blink.cmp',
    'folke/snacks.nvim',
  },
}
