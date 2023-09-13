--[[
Additional coding tools
]]

return {
	{
		"rcarriga/nvim-dap-ui",
		event = "VeryLazy",
		dependencies = "mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup()
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		event = "VeryLazy",
		dependecies = {
			"mfussenegger/nvim-dap",
		},
		opts = {
			enabled = true,
			enabled_commands = false,
			highlilght_changed_variables = true,
			highlight_new_as_changed = true,
			commented = false,
			show_stop_reason = true,
			virt_text_pos = "eol",
			all_frames = false,
		},
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		event = "VeryLazy",
		dependencies = {
			"williamboman/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		opts = {
			ensure_installed = { "codelldb" },
			handlers = {},
		},
	},
	{
		"mfussenegger/nvim-dap"
	},

	-- Comment.nvim
	-- Toggle line and block comments
	{ "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		opts = {
			options = {
				custom_commentstring = function()
					return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
				end,
			},
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		event = "BufEnter",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "M" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			on_attach = function(_)
				local gs = require("gitsigns")
				local nmap = require("utils.remap").nmap
				nmap { "<leader>gb", function() gs.blame_line { full = true } end, desc = "[g]it [b]lame" }
			end,
		},
	},

	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
	},

	-- Hihglight comments
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		opts = {},
	},

	-- Tasks
	{
		"stevearc/overseer.nvim",
		dependecies = {
			"rcarriga/nvim-notify",
		},
		event = "VeryLazy",
		config = true,
	},
}
