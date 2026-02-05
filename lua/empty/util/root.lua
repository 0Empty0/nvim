local M = {}

local function normalize(path)
  return path and vim.fs.normalize(path) or path
end

local function realpath(path)
  if not path or path == "" then
    return nil
  end
  return normalize(vim.uv.fs_realpath(path) or path)
end

function M.cwd()
  return normalize(vim.uv.cwd()) or ""
end

function M.git()
  local root = M.get()
  local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
  local ret = git_root and vim.fn.fnamemodify(git_root, ":h") or root
  return ret
end

function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(buf)
  local path = realpath(filename)
  if not path then
    return M.cwd()
  end

  local roots = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
    if client.config and client.config.root_dir then
      table.insert(roots, client.config.root_dir)
    end
    for _, ws in ipairs(client.workspace_folders or {}) do
      table.insert(roots, vim.uri_to_fname(ws.uri))
    end
  end

  local best
  for _, root in ipairs(roots) do
    root = realpath(root)
    if root and path:find(root, 1, true) == 1 then
      if not best or #root > #best then
        best = root
      end
    end
  end
  if best then
    return opts.normalize and normalize(best) or best
  end

  local marker = vim.fs.root(filename, { ".git", "package.json", "lua" })
  if marker then
    return opts.normalize and normalize(marker) or marker
  end

  return M.cwd()
end

return M
