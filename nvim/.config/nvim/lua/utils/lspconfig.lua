--[[
Helper functions for setting up lsp server
]]

local custom_capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
	custom_capabilities = cmp_nvim_lsp.default_capabilities(custom_capabilities)
end
custom_capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Fix capabilities to not cause conflicts with copilot
custom_capabilities = vim.tbl_deep_extend("force", custom_capabilities, {
	offsetEncoding = { "utf-16" },
	general = {
		positionEncoding = { "utf-16" },
	},
})

local custom_init = function(client)
	client.config.flags = client.config.flags or {}
	client.config.flags.allow_incremental_sync = true
end

local path = require("plenary.path")

local language_libraries = {
	zls = function()
		if (vim.fn.executable "zig") == 1 then
			local zig_info = vim.fn.system "zig env"
			local info = vim.json.decode(zig_info)
			local std_path = path.new(info.std_dir)
			if not std_path:is_absolute() then
				local home = path.new(info.env.HOME)
				std_path = home:joinpath(std_path)
			end

			return tostring(std_path)
		end
		return nil
	end,
}

local custom_attach = function(client, bufnr)
	local remap_utils = require("utils.remap")

	local bnm = function(opts)
		opts[3] = opts[3] or {}
		opts[3].buffer = 0
		if opts.desc then
			opts[3].desc = "lsp: " .. opts.desc
		end
		remap_utils.nmap(opts)
	end

	local bim = function(opts)
		opts[3] = opts[3] or {}
		opts[3].buffer = 0
		if opts.desc then
			opts[3].desc = "lsp: " .. opts.desc
		end
		remap_utils.imap(opts)
	end

	local lspbuf = vim.lsp.buf

	bim { "<C-s>", lspbuf.signature_help, desc = "signature help" }

	bnm { "<leader>cr", lspbuf.rename, desc = "[c]ode [r]ename" }
	bnm { "<leader>ca", lspbuf.code_action, desc = "[c]ode [a]ction" }

	bnm { "gd", lspbuf.definition, desc = "[g]o to [d]efinition" }
	bnm { "gD", lspbuf.declaration, desc = "[g]o to [D]eclaration" }
	bnm { "gt", lspbuf.type_definition, desc = "[g]o to [t]ype definiton" }
	bnm { "K", lspbuf.hover, desc = "hover [K]" }
	bnm { "gi", lspbuf.implementation, desc = "[g]o to [i]mplementation" }

	local has_ts, tsbuiltin = pcall(require, "utils.telescope_custom")
	if has_ts then
		bnm { "gr", tsbuiltin.lsp_references, desc = "[g]o to [r]eferences under cursor" }
		bnm { "gi", tsbuiltin.lsp_implementations, desc = "[g]o to [i]mplementations under cursor" }
		bnm { "<leader>ss", tsbuiltin.lsp_document_symbols, desc = "[s]earch document [s]ymbols" }
		bnm { "<leader>sS", tsbuiltin.lsp_workspace_symbols, desc = "search workspace [S]ymbols" }

		local lib = language_libraries[client.name]
		if lib then
			lib = type(lib) == "function" and lib() or lib
			if type(lib) ~= "string" then
				vim.api.nvim_notify("LSP: library for " .. client.name .. " is not a table", vim.log.levels.ERROR, {})
			else
				bnm { "<leader>sl", tsbuiltin.find_files_in_path(lib), desc = "[s]earch [l]ibrary" }
			end	
		end
	end

	vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"

	-- autocommand helpers
	local augroup_highlights = vim.api.nvim_create_augroup("custom-lsp-references", { clear = true })

	local autocmd_clear = vim.api.nvim_clear_autocmds
	local autocmd_create = vim.api.nvim_create_autocmd

	if client.server_capabilities.documentHighlightProvider then
		autocmd_clear { group = augroup_highlights, buffer = bufnr }
		autocmd_create("CursorHold", {
			buffer = bufnr,
			group = augroup_highlights,
			callback = vim.lsp.buf.document_highlight,
		})
		autocmd_create("CursorMoved", {
			buffer = bufnr,
			group = augroup_highlights,
			callback = vim.lsp.buf.clear_references,
		})
	end

	local has_dap, dap_vscode = pcall(require, "dap.ext.vscode")
	if has_dap then
		dap_vscode.load_launchjs(nil, { cppdbg = { "c", "cpp" } })
	end

	local ft = vim.api.nvim_buf_get_option(0, "filetype")
	if ft == "typescript" or ft == "lua" then
		client.server_capabilities.semanticTokensProvider = nil
	end
end

local M = {}

M.get_codelldb_path = function()
	-- @TODO: make sure it exists. Donwload it if needed
	local mason_codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/"
	return mason_codelldb_path
end

local rust_analyzer, rust_analyzer_cmd = nil, { "rustup", "run", "stable", "rust-analyzer" }
local has_rust_tools, rust_tools = pcall(require, "rust-tools")
if has_rust_tools then
	local codelldb_path = M.get_codelldb_path()
	local exe_path = codelldb_path .. "codelldb"
	local lib_path = codelldb_path .. "liblldb"

	rust_tools.setup {
		server = {
			cmd = rust_analyzer_cmd,
			capabilities = custom_capabilities,
			on_attach = custom_attach,
		},
		dap = {
			adapter = require("rust-tools.dap").get_codelldb_adapter(exe_path, lib_path)
		}
	}
else
	rust_analyzer = {
		cmd = rust_analyzer_cmd,
		settings = {
			["rust_analyzer"] = {
				checkOnSave = {
					command = "clippy",
				},
			},
		},
	}
end

local lsp_servers = {
	bashls = true,
	lua_ls = {
		settings = {
			Lua = {
				workspace = { checkThirdParty = false },
				telemetry = { enable = false },
			},
		},
		before_init = function(config)
			if vim.b.neodev_enabled then
				table.insert(
					config.settings.Lua.workspace.library,
					vim.fn.stdpath "config" .. "/lua"
				)
				print("NEODEV ON")
			end
		end
	},

	pyright = true,
	vimls = true,

	jsonls = {
		settings = {
			json = {
				validate = { enable = true },
			},
		},
	},

	cmake = (1 == vim.fn.executable "cmake-language-server"),

	clangd = {
		cmd = {
			"clangd",
			"--background-index",
			"--suggest-missing-includes",
			"--clang-tidy",
			"--header-insertion=iwyu",
		},
		init_options = {
			clangdFileStatus = true,
		},
	},

	rust_analyzer = rust_analyzer,

	zls = {
		cmd = { "zls" },
		filetypes = { "zig", "zon" },
	},

	gdscript = {},
}

local setup_server = function(server, config)
	if not config then
		return
	end

	if type(config) ~= "table" then
		config = {}
	end

	config = vim.tbl_deep_extend("force", {
		on_init = custom_init,
		on_attach = custom_attach,
		capabilities = custom_capabilities,
	}, config)

	require "lspconfig"[server].setup(config)
end

M.get_server_names = function()
	local res = {}
	local ignored = { "gdscript", "zls" }
	for server, _ in pairs(lsp_servers) do
		if not vim.tbl_contains(ignored, server) then
			table.insert(res, server)
		end
	end
	return res
end

M.setup_all_servers = function()
	-- actual code that setup all the LSPs above
	for server, config in pairs(lsp_servers) do
		setup_server(server, config)
	end
end

return M
