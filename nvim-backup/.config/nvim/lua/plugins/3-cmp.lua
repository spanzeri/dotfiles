return {
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
			"rcarriga/cmp-dap",
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
					local bt = vim.api.nvim_get_option_value("buftype", {buf=0})
					local dap_prompt = vim.tbl_contains({ "dap-repl", "dapui_watches", "dapui_hover" }, bt)
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

					["<C-n>"] = cmp.mapping(function(fallback)
						if cmp.visibile() then
							cmp.select_next_item()
						else
							fallback()
						end
					end),

					["<C-p>"] = cmp.mapping(function(fallback)
						if cmp.visibile() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end),

					["<C-space>"] = cmp.mapping(function(_)
						if cmp.visible() then
							cmp.confirm { select = true }
						else
							cmp.complete()
						end
					end, { "i", "s" }),

					["<C-e>"] = cmp.mapping(function()
						cmp.abort()
					end, { "i", "s" }),
				},

				-- source: according to TJ's config, the order matter (for priority)
				sources = cmp.config.sources({
					--{ name = "copilot" },
					{ name = "nvim_lsp" },
					{ name = "nvim_lua" },
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
}
