vim.opt.nu = true -- line numbers

-- indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

-- have undo tree keep track of everythin in 
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Has to do with searching in vim (not Telescope)
vim.opt.hlsearch = false
vim.opt.incsearch = true
