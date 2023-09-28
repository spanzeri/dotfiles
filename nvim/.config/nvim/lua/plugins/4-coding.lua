return {
	{
		"folke/neodev.nvim",
		opts = {
			override = function(_, library)
				library.enabled = true
				library.plugins = true
			end,
			lspconfig = true,
			pathStrict = true,
		},
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
				-- linters
				"black",
				"isort",
				"clang-format",
			},
		}
	},

	-- lsp config
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"williamboman/mason-lspconfig.nvim",
				cmd = { "LspInstall", "LspUninstall" },
				opts = function()
					return {
						ensure_installed = require("utils.lspconfig").get_server_names(),
					}
				end,
			},
		},
		event = "BufEnter",
		config = function(_, _)
			local lsphelpers = require("utils.lspconfig")
			lsphelpers.setup_all_servers()
		end,
	},

	-- language tools
	{
		"simrat39/rust-tools.nvim",
		ft = { "rs", "toml" },
	},

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
}
