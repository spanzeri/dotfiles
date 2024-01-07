return {
	-- lsp config
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"williamboman/mason-lspconfig.nvim",
				cmd = { "LspInstall", "LspUninstall" },
				opts = function()
					return {
						ensure_installed = require("sam.lsp-config").get_ensure_installed(),
					}
				end,
			},
			"folke/neodev.nvim",
		},
		event = "BufEnter",
		config = function(_, _)
			require("neodev").setup({
				override = function()
					library.enabled = true
					library.plugins = true
				end,
			})
			require("sam.lsp-config").setup_all()
		end,
	},

	-- mason lsp server installer
	{
		"williamboman/mason.nvim",
		cmd = {
			"Mason",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
			"MasonLog",
			"MasonUpdate",
			"MasonUpdateAll",
		},
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_uninstalled = "✗",
					package_pending = "⟳",
				},
			},
		},
		build = ":MasonUpdate",
	},

	-- mason tool installer (for daps)
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		opts = {
			auto_update = true,
			debounce_hours = 24,
			ensure_installed = {
				"clang-format",
			},
		}
	},

	-- rust lsp auto-conf and tools
	{
		'mrcjkb/rustaceanvim',
		version = '^3',
		ft = { 'rust' },
	},

	-- zig support
	{
		"ziglang/zig.vim",
		ft = { "zig" },
		config = function(_, _)
			vim.filetype.add({
				extension = {
					zon = "zig",
				},
			})
			vim.g.zig_fmt_autosave=false
		end
	},

	-- Markdown preview
	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = function() vim.fn["mkdp#util#install"]() end,
	},

	{
		"b0o/SchemaStore.nvim",
	},

	-- Copilot
	{
		"github/copilot.vim",
		event = "InsertEnter",
		init = function()
			vim.api.nvim_set_keymap("i", "<C-y>", 'copilot#Accept("CR")', { expr = true, silent = true, noremap = true })
			vim.api.nvim_set_keymap("i", "<C-t>", 'copilot#AcceptLine()', { expr = true, silent = true, noremap = true })
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_assume_mapped = true
		end,
		config = function(_, _)
			vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#555555", italic = true })
		end,
	},

	-- dap
	{
		"rcarriga/nvim-dap-ui",
		event = "VeryLazy",
		dependencies = "mfussenegger/nvim-dap",
		config = function()
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

	-- Hihglight comments
	{
		"folke/todo-comments.nvim",
		event = "VeryLazy",
		opts = {},
	},
}
