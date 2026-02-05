---Autoformatting helpers and user commands.
---@type EmptyUtil
local Util = require("empty.util")

---@class EmptyFormat
---@field enabled fun(bufnr?: integer): boolean
---@field enable fun(enable: boolean, buffer_only?: boolean)
---@field toggle fun(buffer_only?: boolean)
---@field info fun(bufnr?: integer)
---@field format fun(opts?: { buf?: integer, force?: boolean })
---@field setup fun()

---@class EmptyFormat
local M = {}

---Check whether autoformatting is enabled.
---@param bufnr? integer Buffer handle.
---@return boolean
function M.enabled(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local local_value = vim.b[bufnr].autoformat
  if local_value ~= nil then
    return local_value
  end
  if vim.g.autoformat == nil then
    return true
  end
  return vim.g.autoformat
end

---Enable or disable autoformatting.
---@param enable boolean
---@param buffer_only? boolean When true, only set the buffer-local flag.
function M.enable(enable, buffer_only)
  if buffer_only then
    vim.b.autoformat = enable
    return
  end
  vim.g.autoformat = enable
  vim.b.autoformat = nil
end

---Toggle autoformatting and show status.
---@param buffer_only? boolean When true, toggle only the buffer-local flag.
function M.toggle(buffer_only)
  local new_state = not M.enabled()
  M.enable(new_state, buffer_only)
  M.info()
end

---Show autoformat status and formatter info.
---@param bufnr? integer Buffer handle.
function M.info(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local enabled = M.enabled(bufnr)
  local lines = {
    "Autoformat: " .. (enabled and "enabled" or "disabled"),
  }

  local ok, conform = pcall(require, "conform")
  if ok then
    local formatters = conform.list_formatters(bufnr)
    if #formatters > 0 then
      lines[#lines + 1] = "Formatters:"
      for _, item in ipairs(formatters) do
        lines[#lines + 1] = "- " .. item.name
      end
    else
      lines[#lines + 1] = "Formatters: none"
    end
  else
    lines[#lines + 1] = "Formatters: LSP only"
  end

  Util.info(lines, { title = "Format" })
end

---Format the buffer using Conform or LSP.
---@param opts? { buf?: integer, force?: boolean }
function M.format(opts)
  opts = opts or {}
  local bufnr = opts.buf or vim.api.nvim_get_current_buf()
  if not (opts.force or M.enabled(bufnr)) then
    return
  end

  local ok, conform = pcall(require, "conform")
  if ok then
    local formatters = conform.list_formatters(bufnr)
    if #formatters > 0 then
      conform.format({ bufnr = bufnr })
      return
    end
  end

  if vim.lsp.buf.format then
    vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 3000 })
  end
end

---Setup formatting autocommands and user commands.
function M.setup()
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("EmptyFormat", { clear = true }),
    callback = function(event)
      M.format({ buf = event.buf })
    end,
  })

  vim.api.nvim_create_user_command("Format", function()
    M.format({ force = true })
  end, { desc = "Format buffer or selection" })

  vim.api.nvim_create_user_command("FormatInfo", function()
    M.info()
  end, { desc = "Show formatter info" })

  vim.api.nvim_create_user_command("FormatToggle", function()
    M.toggle(false)
  end, { desc = "Toggle autoformat (global)" })

  vim.api.nvim_create_user_command("FormatToggleBuffer", function()
    M.toggle(true)
  end, { desc = "Toggle autoformat (buffer)" })
end

return M
