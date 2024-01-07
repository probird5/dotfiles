vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set relativenumber")
vim.g.mapleader = " "
vim.api.nvim_set_keymap('i', '<C-b>', '<cmd>lua require("cmp").mapping.scroll_docs(-4)<CR>', { noremap = true, silent = true, expr = true })


