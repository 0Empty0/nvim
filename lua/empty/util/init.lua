---Utility helpers for notifications and undo breaks.
---@class EmptyUtil
---@field CREATE_UNDO string
---@field info fun(msg: string|string[], opts?: table)
---@field warn fun(msg: string|string[], opts?: table)
---@field error fun(msg: string|string[], opts?: table)
---@field create_undo fun()

---@class EmptyUtil
local M = {}

---Notify with consistent defaults.
---@param msg string|string[] Message text or list of lines.
---@param level integer Log level from `vim.log.levels`.
---@param opts? table Additional options for `vim.notify`.
local function notify(msg, level, opts)
	opts = opts or {}
	opts.title = opts.title or "empty.nvim"
	if type(msg) == "table" then
		msg = table.concat(msg, "\n")
	end
	vim.notify(msg, level, opts)
end

---Show an info notification.
---@param msg string|string[] Message text or list of lines.
---@param opts? table Additional options for `vim.notify`.
function M.info(msg, opts)
	notify(msg, vim.log.levels.INFO, opts)
end

---Show a warning notification.
---@param msg string|string[] Message text or list of lines.
---@param opts? table Additional options for `vim.notify`.
function M.warn(msg, opts)
	notify(msg, vim.log.levels.WARN, opts)
end

---Show an error notification.
---@param msg string|string[] Message text or list of lines.
---@param opts? table Additional options for `vim.notify`.
function M.error(msg, opts)
	notify(msg, vim.log.levels.ERROR, opts)
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
---Insert an undo break in insert mode.
function M.create_undo()
	if vim.api.nvim_get_mode().mode == "i" then
		vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
	end
end

return M
