local M = {}

local pkg_cache = {}

local function read_package_json(path)
  if pkg_cache[path] ~= nil then
    return pkg_cache[path]
  end
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    pkg_cache[path] = false
    return false
  end
  local ok_json, data = pcall(vim.fn.json_decode, table.concat(lines, "\n"))
  if not ok_json or type(data) ~= "table" then
    pkg_cache[path] = false
    return false
  end
  pkg_cache[path] = data
  return data
end

local function start_dir(ctx)
  if ctx and ctx.dirname and ctx.dirname ~= "" then
    return ctx.dirname
  end
  if ctx and ctx.filename and ctx.filename ~= "" then
    return vim.fs.dirname(ctx.filename)
  end
  return vim.uv.cwd()
end

local function has_file(ctx, names)
  return vim.fs.find(names, { path = start_dir(ctx), upward = true })[1] ~= nil
end

local function package_has_key(ctx, key)
  local pkg = vim.fs.find("package.json", { path = start_dir(ctx), upward = true })[1]
  if not pkg then
    return false
  end
  local data = read_package_json(pkg)
  return type(data) == "table" and data[key] ~= nil
end

function M.has_biome_config(ctx)
  if has_file(ctx, { "biome.json", "biome.jsonc" }) then
    return true
  end
  return package_has_key(ctx, "biome") or package_has_key(ctx, "biomejs")
end

function M.has_prettier_config(ctx)
  if
      has_file(ctx, {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.js",
        ".prettierrc.cjs",
        ".prettierrc.mjs",
        ".prettierrc.yaml",
        ".prettierrc.yml",
        "prettier.config.js",
        "prettier.config.cjs",
        "prettier.config.mjs",
        "prettier.config.ts",
      })
  then
    return true
  end
  return package_has_key(ctx, "prettier")
end

function M.has_eslint_config(ctx)
  if
      has_file(ctx, {
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.mjs",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        "eslint.config.js",
        "eslint.config.cjs",
        "eslint.config.mjs",
        "eslint.config.ts",
      })
  then
    return true
  end
  return package_has_key(ctx, "eslintConfig")
end

return M
