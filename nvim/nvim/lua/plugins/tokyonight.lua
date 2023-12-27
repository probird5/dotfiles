return  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    lazy = false,
    priority = 1000,
    opts = {},
-- config for lazy to call
    config = function()
      vim.cmd.colorscheme "tokyonight"
    end
}

