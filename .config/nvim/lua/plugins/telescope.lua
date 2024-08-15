return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local builtin = require("telescope.builtin")
		-- Telescope keybindings
		vim.keymap.set("n", "<leader>ff", function()
			-- Use the hidden option to search hidden files and directories
			builtin.find_files({ hidden = true })
		end, {})
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
	end,
}
