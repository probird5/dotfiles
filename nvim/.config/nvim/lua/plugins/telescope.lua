return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local builtin = require("telescope.builtin")
		local telescope = require("telescope")

		-- Telescope setup with configuration for previewer
		telescope.setup {
			defaults = {
				layout_strategy = "horizontal",
				layout_config = {
					preview_width = 0.6, -- Adjust preview window width
				},
			},
			pickers = {
				lsp_definitions = {
					theme = "dropdown", -- Optional, can be removed if not needed
					previewer = true,   -- Enable preview for definitions
				},
			},
		}

		-- Telescope keybindings
		vim.keymap.set("n", "<leader>ff", function()
			-- Use the hidden option to search hidden files and directories
			builtin.find_files({ hidden = true })
		end, {})
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>fb", builtin.buffers, {})

		-- Keybinding for LSP definitions with preview
		vim.keymap.set("n", "gd", builtin.lsp_definitions, { noremap = true, silent = true })
	end,
}

