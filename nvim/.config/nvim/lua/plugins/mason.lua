return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "clangd",
          "html",
          "rust_analyzer",
          "pyright",
          "gopls",
          "bashls",
          "yamlls",
          "ts_ls",
        },
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "stylua",
          "clang-format",
          "gofumpt",
          "goimports-reviser",
          "golangci-lint",
          "prettier",
          "black",
          "ruff",
          "shfmt",
        },
      })
    end,
  },
}

