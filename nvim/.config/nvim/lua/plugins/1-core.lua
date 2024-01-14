return {
	"nvim-lua/plenary.nvim",
	"nvim-tree/nvim-web-devicons",

	-- better repeat
	{
		"tpope/vim-repeat",
		event = "VeryLazy",
	},

	-- undotree
	{
		"mbbill/undotree",
		event = "VeryLazy",
	},

	-- session management
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" } },
		keys = {
			{ "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
			{ "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
			{ "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
		},
	},

	-- colorscheme
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		opt = {
			background = {
				dark = "dragon",
			},
		},
		config = function(_, opts)
			require("kanagawa").setup(opts)
			vim.cmd [[colorscheme kanagawa]]
		end,
	},

	-- FZF telescope extensions
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		enabled = vim.fn.executable "cmake" == 1,
		build = {
			"cmake -S . -Bbuild -DCMAKE_BUILD_TYPE=Release",
			"cmake --build build --config Release",
			"cmake --install build --prefix build"
		},
		lazy = false,
	},

	-- Telescope (fuzzy searching everything)
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		cmd = "Telescope",
		opts = {
			defauts = {
				winblend = 5,
				layout_config = {
					width = 200,
					vertical = {
						preview_width = 110,
						cutoff = 180,
					},
					height = 0.5,
				},
				shorten_path = true,
			},
			pickers = {
				colorscheme = {
					enable_preview = true,
				},
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			telescope.load_extension("fzf")
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "BufEnter",
		opts = function()
			local highlight = {
				"CursorColumn",
				"Whitespace",
			}
			return {
				exclude = {
					buftypes = {
						"nofile",
						"terminal",
						"quickfix",
						"prompt",
					},
					filetypes = {
						"help",
						"TelescopePrompt",
						"TelescopeResult",
						"man",
						"lazy",
						"neo-tree",
						"lspinfo",
					},
				},
				scope = { enabled = true },
				indent = { smart_indent_cap = true },
				indent = { char = "│", tab_char = "│" },
			}
		end,
	},

	-- Better input and select UI
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {
			input = {
				default_prompt = "➤ ",
				win_options = { winhighlight = "Normal:Normal,NormalNC:Normal" },
			},
			select = {
				builtin = {
					win_options = { winhighlight = "Normal:Normal,NormalNC:Normal" },
				},
			},
		},
		config = function(_, opts)
			require("dressing").setup(opts)
		end,
	},

	-- On screen key helpers
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			icons = { group = vim.g.icons_enabled and "" or "+", separator = "" },
			disable = { filetypes = { "TelescopePrompt" } },
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.register({
				b = { name = "Buffer" },
				d = { name = "Diagnostic|Debug" },
				e = { name = "Errors" },
				g = { name = "Git" },
				o = { name = "Org" },
				q = { name = "Session" },
				s = { name = "Search" },
				t = { name = "tab" },
				T = { name = "Treesiteer" },
				u = { name = "Undo" },
				x = { name = "Source" },
				}, { prefix = "<leader>" })
		end,
	},

	-- Notifications
	{
		"rcarriga/nvim-notify",
		event = "VeryLazy",
		config = function()
			vim.notify = require("notify")
		end
	},

	-- remove buffer
	{
		"echasnovski/mini.bufremove",
		-- stylua: ignore
		keys = {
			{ "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete Buffer" },
			{ "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
		},
	},

	-- surround
	{
		"echasnovski/mini.surround",
		keys = function(_, keys)
			-- Populate the keys based on the user's options
			local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
			local opts = require("lazy.core.plugin").values(plugin, "opts", false)
			local mappings = {
				{ opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
				{ opts.mappings.delete, desc = "Delete surrounding" },
				{ opts.mappings.find, desc = "Find right surrounding" },
				{ opts.mappings.find_left, desc = "Find left surrounding" },
				{ opts.mappings.highlight, desc = "Highlight surrounding" },
				{ opts.mappings.replace, desc = "Replace surrounding" },
				{ opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
			}
			mappings = vim.tbl_filter(function(m)
				return m[1] and #m[1] > 0
			end, mappings)
			return vim.list_extend(mappings, keys)
		end,
		opts = {
			mappings = {
				add = "gsa", -- Add surrounding in Normal and Visual modes
				delete = "gsd", -- Delete surrounding
				find = "gsf", -- Find surrounding (to the right)
				find_left = "gsF", -- Find surrounding (to the left)
				highlight = "gsh", -- Highlight surrounding
				replace = "gsr", -- Replace surrounding
				update_n_lines = "gsn", -- Update `n_lines`
			},
		},
	},

	-- align text object
	{
		"echasnovski/mini.align",
		event = "VeryLazy",
		opts = {},
	},

	-- session management
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" } },
		keys = {
			{ "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
			{ "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
			{ "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
		},
	},

	-- git support
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
	},
}

