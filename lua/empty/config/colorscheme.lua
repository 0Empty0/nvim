local scheme = vim.g.colorscheme or "rose-pine"

local ok = pcall(vim.cmd.colorscheme, scheme)
if not ok then
  vim.notify(("Colorscheme not found: %s"):format(scheme), vim.log.levels.WARN)
  pcall(vim.cmd.colorscheme, "habamax")
end
