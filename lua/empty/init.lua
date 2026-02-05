require "empty.config.lazy"

require "empty.config.options"
require "empty.config.colorscheme"
require "empty.config.autocmds"

vim.schedule(function()
  require "empty.config.mappings"
end)
