local function setup(name, fn)
  local ok, err = pcall(fn)
  if not ok then
    vim.schedule(function()
      vim.notify(("%s setup failed: %s"):format(name, err), vim.log.levels.WARN)
    end)
  end
end

setup("tokyonight", function()
  vim.cmd.colorscheme("tokyonight")
end)

setup("snacks", function()
  require("snacks").setup({
    input = {},
    picker = {
      actions = {
        opencode_send = function(...)
          return require("opencode").snacks_picker_send(...)
        end,
      },
      win = {
        input = {
          keys = {
            ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
          },
        },
      },
    },
    dashboard = {
      preset = {
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
          { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "u", desc = "Update Packages", action = ":lua vim.pack.update()" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        {
          text = {
            {
              (function()
                local h = tonumber(os.date("%H"))
                if h < 5 then
                  return "    Good night!"
                elseif h < 12 then
                  return "    Good morning!"
                elseif h < 17 then
                  return "    Good afternoon!"
                elseif h < 20 then
                  return "    Good evening!"
                else
                  return "    Good night!"
                end
              end)(),
              hl = "SnacksDashboardHeader",
            },
          },
          align = "center",
          padding = 1,
        },
      },
    },
  })
end)

setup("mason", function()
  require("mason").setup()
  require("mason-lspconfig").setup({
    ensure_installed = {
      "lua_ls",
      "clangd",
      "html",
      "nixd",
      "rust_analyzer",
      "pyright",
      "ruff",
      "gopls",
      "bashls",
      "yamlls",
      "ts_ls",
    },
  })
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
      "nixfmt",
      "shfmt",
    },
  })
end)

setup("lsp", function()
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP hover" })
  vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to definition" })
  vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Find references" })
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
  vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format buffer" })

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client:supports_method("textDocument/completion") then
        vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      end
    end,
  })
end)

setup("native-completion", function()
  vim.opt.completeopt = { "menu", "menuone", "noinsert", "popup" }
  vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger LSP completion" })
  vim.keymap.set("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
  end, { expr = true, desc = "Next completion item" })
  vim.keymap.set("i", "<S-Tab>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
  end, { expr = true, desc = "Previous completion item" })
end)

setup("none-ls", function()
  local null_ls = require("null-ls")
  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.clang_format,
      null_ls.builtins.formatting.gofumpt,
      null_ls.builtins.formatting.goimports_reviser,
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.black,
      null_ls.builtins.formatting.nixfmt,
      null_ls.builtins.formatting.shfmt,
      null_ls.builtins.diagnostics.golangci_lint,
    },
  })
end)

setup("telescope", function()
  local builtin = require("telescope.builtin")
  require("telescope").setup({
    defaults = {
      layout_strategy = "horizontal",
      layout_config = {
        preview_width = 0.6,
      },
      preview = {
        treesitter = false,
      },
    },
    pickers = {
      lsp_definitions = {
        theme = "dropdown",
        previewer = true,
      },
    },
  })

  vim.keymap.set("n", "<leader>ff", function()
    builtin.find_files({ hidden = true })
  end, { desc = "Find files" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
  vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
  vim.keymap.set("n", "gd", builtin.lsp_definitions, { desc = "LSP definitions" })
end)

setup("lualine", function()
  require("lualine").setup({
    options = {
      theme = "iceberg_dark",
    },
  })
end)

setup("autopairs", function()
  require("nvim-autopairs").setup({})
end)

setup("oil", function()
  _G.CustomOilBar = function()
    local path = vim.fn.expand("%")
    path = path:gsub("oil://", "")
    return "  " .. vim.fn.fnamemodify(path, ":.")
  end

  require("oil").setup({
    columns = { "icon" },
    keymaps = {
      ["<C-h>"] = false,
      ["<C-l>"] = false,
      ["<C-k>"] = false,
      ["<C-j>"] = false,
      ["<M-h>"] = "actions.select_split",
    },
    win_options = {
      winbar = "%{v:lua.CustomOilBar()}",
    },
    view_options = {
      show_hidden = true,
    },
  })

  vim.keymap.set("n", "<BS>", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  vim.keymap.set("n", "<space>-", require("oil").toggle_float, { desc = "Open parent directory float" })
end)

setup("neo-tree", function()
  vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", { desc = "Neo-tree filesystem" })
  vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", { desc = "Neo-tree buffers" })
end)

setup("tmux-navigator", function()
  vim.keymap.set("n", "<C-h>", ":TmuxNavigateLeft<CR>", { desc = "Tmux left" })
  vim.keymap.set("n", "<C-l>", ":TmuxNavigateRight<CR>", { desc = "Tmux right" })
  vim.keymap.set("n", "<C-j>", ":TmuxNavigateDown<CR>", { desc = "Tmux down" })
  vim.keymap.set("n", "<C-k>", ":TmuxNavigateUp<CR>", { desc = "Tmux up" })
end)

setup("obsidian", function()
  require("obsidian").setup({
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/Notes/notes-improved",
      },
    },
  })

  vim.keymap.set("n", "<leader>oc", "<cmd>lua require('obsidian').util.toggle_checkbox()<CR>", { desc = "Obsidian checkbox" })
  vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTemplate<CR>", { desc = "Insert Obsidian template" })
  vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", { desc = "Open in Obsidian" })
  vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Obsidian backlinks" })
  vim.keymap.set("n", "<leader>ol", "<cmd>ObsidianLinks<CR>", { desc = "Obsidian links" })
  vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Create Obsidian note" })
  vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search Obsidian" })
  vim.keymap.set("n", "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Obsidian quick switch" })
end)

setup("opencode", function()
  vim.g.opencode_opts = {}
  vim.o.autoread = true

  vim.keymap.set({ "n", "x" }, "<C-a>", function()
    require("opencode").ask("@this: ", { submit = true })
  end, { desc = "Ask opencode" })
  vim.keymap.set({ "n", "x" }, "<C-x>", function()
    require("opencode").select()
  end, { desc = "Execute opencode action" })
  vim.keymap.set({ "n", "t" }, "<C-.>", function()
    require("opencode").toggle()
  end, { desc = "Toggle opencode" })
  vim.keymap.set({ "n", "x" }, "go", function()
    return require("opencode").operator("@this ")
  end, { desc = "Add range to opencode", expr = true })
  vim.keymap.set("n", "goo", function()
    return require("opencode").operator("@this ") .. "_"
  end, { desc = "Add line to opencode", expr = true })
  vim.keymap.set("n", "<S-C-u>", function()
    require("opencode").command("session.half.page.up")
  end, { desc = "Scroll opencode up" })
  vim.keymap.set("n", "<S-C-d>", function()
    require("opencode").command("session.half.page.down")
  end, { desc = "Scroll opencode down" })
  vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
  vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
end)
