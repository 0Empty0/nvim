return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        -- lua
        "lua-language-server",
        "stylua",

        -- bash
        "shfmt",

        -- web
        "css-lsp",
        "html-lsp",
        "typescript-language-server",
        "deno",
        "prettier",
        "biome",
        "vtsls",
        "tailwindcss-language-server",
        "vue-language-server",
        "svelte-language-server",
        "astro-language-server",
        "json-lsp",
        "prisma-language-server",
        "js-debug-adapter",

        -- sql
        "sqlfluff",

        --rust
        "codelldb",
        "bacon",

        -- markdown
        "markdownlint-cli2",
        "markdown-toc",

        -- go
        "goimports",
        "gofumpt",
        "golangci-lint",

        -- csharp
        "csharpier",
        "netcoredbg",
        "fantomas",

        "hadolint",

        "cmakelang",
        "cmakelint",

        "black"
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local seen = {}
      local tools = {}
      for _, tool in ipairs(opts.ensure_installed or {}) do
        if not seen[tool] then
          seen[tool] = true
          table.insert(tools, tool)
        end
      end
      local registry = require("mason-registry")
      registry.refresh(function()
        for _, tool in ipairs(tools) do
          local ok, pkg = pcall(registry.get_package, tool)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end)
    end,
  },
}
