return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use the latest release
  lazy = true,
  ft = "markdown", -- Only load for markdown files
  -- Uncomment and configure the lines below if you want to limit to specific vault files
  -- event = {
  --   "BufReadPre " .. vim.fn.expand("~/path/to/my-vault/*.md"),
  --   "BufNewFile " .. vim.fn.expand("~/path/to/my-vault/*.md"),
  -- },
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required dependency
    -- Add optional dependencies here if needed
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/all-notest",
      },
    },
  },
  config = function()
    -- Define key mappings for obsidian.nvim
    vim.keymap.set(
      "n",
      "<leader>oc",
      "<cmd>lua require('obsidian').util.toggle_checkbox()<CR>",
      { desc = "Obsidian Check Checkbox" }
    )
    vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTemplate<CR>", { desc = "Insert Obsidian Template" })
    vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", { desc = "Open in Obsidian App" })
    vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Show Obsidian Backlinks" })
    vim.keymap.set("n", "<leader>ol", "<cmd>ObsidianLinks<CR>", { desc = "Show Obsidian Links" }) -- Fixed missing parenthesis
    vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Create New Note" })
    vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search Obsidian" })
    vim.keymap.set("n", "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick Switch" })
  end,
}

