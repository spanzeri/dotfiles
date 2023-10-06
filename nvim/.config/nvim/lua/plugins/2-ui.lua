--[[
Improve or add to the UI
]]

return {
	-- Colorscheme
	{
		"AlexvZyl/nordic.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			italic_comments = false,
		},
		config = function(plugin, opts)
			require("nordic").setup(opts)
			vim.cmd.colorscheme("nordic")
		end
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		opts = function()
			local fullfilepath = function()
				local bt = vim.api.nvim_buf_get_option(0, "buftype")
				if bt ~= "" then
					local filename = vim.fn.expand("%:t")
					if bt == "help" then
						filename = filename .. " [󰋖]"
					elseif bt == "terminal" then
						filename = filename .. " []"
					end
					return filename
				end

				local path = vim.fn.expand("%:p:~:.")
				if string.len(path) > 45 then
					path = "..." .. string.sub(path, -42)
				end
 				-- path = string.gsub(path, "\\", "  ")
				-- path = string.gsub(path, "/", "  ")
				path = "  " .. path

				if vim.api.nvim_buf_get_option(0, "modified") then
					path = path .. " []"
				end
				if vim.api.nvim_buf_get_option(0, "readonly") then
					path = path .. " []"
				end

				return path
			end

			local has_overseer, _ = pcall(require, "overseer")

			return {
				options = {
					theme = "auto",
					component_separators = { left = "╱", right = "╲" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_c = { fullfilepath },
					lualine_x = has_overseer and { "overseer" } or nil,
				},
			}
		end,
		event = "VeryLazy",
	},

	-- Highlight colors in text
	{
		"norcalli/nvim-colorizer.lua",
		event = "BufEnter",
	},

	-- File browser
	{
		"nvim-neo-tree/neo-tree.nvim",
		init = function()
			vim.g.neo_tree_remove_legacy_commands = true
		end,
		opts = {
			close_if_last_window = true,
			width = 40,
		},
		cmd = "Neotree",
		keys = {
			{ "\\", "<cmd>Neotree reveal_force_cwd<CR>", desc = "open filetree", noremap = true },
			{ "|", "<cmd>Neotree show toggle<CR>", desc = "toggle filetree", noremap = true },
		},
	},

	-- Indent (guide)lines
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "BufEnter",
		opts = {
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
		},
	},

	{
		"nvim-telescope/telescope-fzf-native.nvim",
		enabled = vim.fn.executable "cmake" == 1,
		build = {
			"cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release",
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

	-- Better ui elemets (input and select)
	{
		"stevearc/dressing.nvim",
		init = function()
			local lh = require("utils.lazy")
			lh.load_plugin_with_function("dressing.nvim", vim.ui, { "input", "select" })
		end,
		opts = {
			input = {
				default_prompt = "➤ ",
				win_options = { winhighlight = "Normal:Normal,NormalNC:Normal" },
			},
			select = {
				backend = { "telescope", "builtin" },
				builtin = {
					win_options = { winhighlight = "Normal:Normal,NormalNC:Normal" },
				},
			},
		},
	},

	--  LSP icons [icons]
	{
		"onsails/lspkind.nvim",
		opts = {
			mode = "symbol",
			symbol_map = {
				Array = "󰅪",
				Boolean = "⊨",
				Class = "󰌗",
				Constructor = "",
				Key = "󰌆",
				Namespace = "󰅪",
				Null = "NULL",
				Number = "#",
				Object = "󰀚",
				Package = "󰏗",
				Property = "",
				Reference = "",
				Snippet = "",
				String = "󰀬",
				TypeParameter = "󰊄",
				Unit = "",
			},
			menu = {},
		},
		enabled = vim.g.icons_enabled,
		config = function(_, opts)
			require("lspkind").init(opts)
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
				c = { name = "Code" },
				d = { name = "Diagnostic|Debug" },
				e = { name = "Errors" },
				g = { name = "Git" },
				o = { name = "Org" },
				q = { name = "Session" },
				s = { name = "Search" },
				t = { name = "Treesiteer" },
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
}
