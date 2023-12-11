vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "

-- Adding lazy.nvim plugin manager

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


local plugins = {
-- added the name for tokyo night
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    lazy = false,
    priority = 1000,
    opts = {},
  },
-- Fuzzy finder of choice
  {
      'nvim-telescope/telescope.nvim', tag = '0.1.5',
      dependencies = { 'nvim-lua/plenary.nvim' }
  },

-- Tree sitter
  {
    "nvim-treesitter/nvim-treesitter", build = ":TSUpdate"
  }


}

local opts = {}

require("lazy").setup(plugins, opts)
local builtin = require("telescope.builtin")

-- Treesitter config
local configs = require("nvim-treesitter.configs")

configs.setup({
  ensure_installed = { "c", "lua", "vim", "python", "go", "bash" },
  sync_install = false,
  highlight = { enable = true },
  indent = { enable = true },

  })

-- Telescope keybindings
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

-- Calling tokyo night
require("tokyonight").setup()
vim.cmd.colorscheme "tokyonight"
