--[[
Core plugins for editing
]]

return {
	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/playground",
			{
				"nvim-treesitter/nvim-treesitter-context",
				opts = {
					enabled = true,
				}
			}
		},
		keys = {
			{ "<leader>tp", "<cmd>TSPlaygroundToggle<CR>", desc = "[t]reesitter [p]layground" },
			{ "<leader>th", "<cmd>TSHighlightCaptureUnderCursor<CR>", desc = "[t]reesitter [h]ighlight under cursor" },
		},
		event = "BufEnter",
		cmd = {
			"TSBufDisable",
			"TSBufEnable",
			"TSBufToggle",
			"TSDisable",
			"TSEnable",
			"TSToggle",
			"TSInstall",
			"TSInstallInfo",
			"TSInstallSync",
			"TSModuleInfo",
			"TSUninstall",
			"TSUpdate",
			"TSUpdateSync",
		},
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"cmake",
				"cpp",
				"glsl",
				"go",
				"hlsl",
				"json",
				"lua",
				"markdown",
				"meson",
				"org",
				"python",
				"rust",
				"toml",
				"vim",
				"vimdoc",
				"zig",
			},

			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },

			incremental_selection = {
				enable = true,
				lookahead = true,
				keymaps = {
					init_selection = "<C-s>",
					node_incremental = "<C-s>",
					scope_incremental = "<C-S>",
					node_decremental = "<M-s>",
				},
			},

			context_commentstring = {
				enable = true,
				enable_autocmd = false,
				config = {
					c = "// %s",
					lua = "-- %s",
				},
			},

			textobjects = {
				move = {
					enable = true,
					set_jumps = true,

					goto_next_start = {
						["]p"] = "@parameter.inner",
						["]m"] = "@function.outer",
						["]]"] = "@class.outer",
					},
					goto_next_end = {
						["]M"] = "@function.outer",
						["]["] = "@class.outer",
					},
					goto_previous_start = {
						["[p"] = "@parameter.inner",
						["[m"] = "@function.outer",
						["[["] = "@class.outer",
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
						["[]"] = "@class.outer",
					},
				},

				select = {
					enable = true,
					lookahead = true,

					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",

						["ac"] = "@conditional.outer",
						["ic"] = "@conditional.inner",

						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",

						["av"] = "@variable.outer",
						["iv"] = "@variable.inner",
					},
				},
			},

			playground = {
				enable = true,
				updatetime = 25,
				persist_queries = true,
				keybindings = {
					toggle_query_editor = "o",
					toggle_hl_groups = "i",
					toggle_injected_languages = "t",
					toggle_anonymous_nodes = "a",
					toggle_language_display = "I",
					focus_language = "f",
					unfocus_language = "F",
					update = "R",
					goto_node = "<cr>",
					show_help = "?",
				},
			},
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
		end,
	},

	-- lua ref in vim help
	{
		"milisims/nvim-luaref",
		event = "VeryLazy",
	},

	-- snippets
	{
		"L3MON4D3/LuaSnip",
		dependecies = {
			"rafamadriz/friendly-snippets",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
		build = "make install_jsregexp",
	},

	-- auto-completion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			{ "saadparwaiz1/cmp_luasnip", dependencies = { "L3MON4D3/LuaSnip" } },
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp",
			"onsails/lspkind.nvim",
		},
		event = "InsertEnter",
		opts = function()
			local cmp = require("cmp")

			local luasnip = require("luasnip")
			local lspkind = require("lspkind")

			local has_word_before = function()
				local unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			return {
				enabled = function()
					local lh = require("utils.lazy")
					local bt = vim.api.nvim_get_option_value("buftype", {buf=0})
					local dap_prompt = lh.has_plugin("cmp-dap") and vim.tbl_contains(
						{ "dap-repl", "dapui_watches", "dapui_hover" }, bt)
					if bt == "prompt" and not dap_prompt then
						return false
					end

					return true
				end,

				preselect = cmp.PreselectMode.None,
				formatting = {
					format = lspkind.cmp_format {
						with_text = true,
						menu = {
							buffer = "[buf]",
							nvim_lsp = "[LSP]",
							nvim_lua = "[api]",
							path = "[path]",
							luasnip = "[snip]",
							gh_issues = "[issues]",
							tn = "[TabNine]",
							eruby = "[erb]",
							cody = "[cody]",
						},
					},
				},
				snippet = {
					expand = function(args) luasnip.lsp_expand(args.body) end,
				},
				confirm_opts = {
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				},
				mapping = {
					["<tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						elseif has_word_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),

					["<C-space>"] = cmp.mapping(function(_)
						if cmp.visible() then
							cmp.confirm { select = true }
						else
							cmp.complete()
						end
					end, { "i", "s" }),
				},

				-- source: according to TJ's config, the order matter (for priority)
				sources = cmp.config.sources({
					{ name = "nvim_lua" },
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				} , {
					{ name = "path" },
					{ name = "buffer", keyword_length = 5 },
				}),

				-- sorting (prefer members that do not start with _)
				sorting = {
					comparators = {
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,

						function(e1, e2)
							local _, e1_starts_under = e1.completion_item.label:find("^_+")
							local _, e2_starts_under = e2.completion_item.label:find("^_+")
							e1_starts_under = e1_starts_under or 0
							e2_starts_under = e2_starts_under or 0
							if e1_starts_under > e2_starts_under then
								return false
							elseif e1_starts_under < e2_starts_under then
								return true
							end
						end,

						cmp.config.compare.kind,
						cmp.config.compare.sort_text,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
			}
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

	-- global rename
	{
		"nvim-pack/nvim-spectre",
		cmd = "Spectre",
		opts = { open_cmd = "noswap vnew" },
		keys = {
			{ "<leader>rf", function() require("spectre").open() end, desc = "[r]eplace in [f]iles" },
			{ "<leader>rw", function() require("spectre").open({ select_word = true }) end, desc = "[r]eplace in [w]ord in files" },
		},
	}
}
