local log = require("sam.logging")

-- Server configuration
local lsp_servers = {
	bashls = {},

	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},

	pyright = {},
	vimls = {},

	jsonls = {
		settings = {
			json = {
				validate = { enable = true },
			},
		},
	},

	cmake = (vim.fn.executable("cmake-language-server") == 1) and {} or nil,

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

	zls = {
		cmd = { "zls" },
		filetypes = { "zig", "zon" },
	},

	gdscript = {},

	tsserver = {
		filetypes = { "typescript", "typescript.tsx" },
		cmd = { "typescript-language-server", "--stdio" },
	},
}


local custom_capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
	custom_capabilities = cmp_nvim_lsp.default_capabilities()
else
	log.warn("Missing cmp_nvim_lsp. Lsp completion will be limited")
end
custom_capabilities.textDocument.completion.completionItem.snippetSupport = true

-- fix compatbitility with copilot
custom_capabilities = vim.tbl_deep_extend("force", custom_capabilities, {
	offsetEncoding = { "utf-16" },
	general = {
		positionEncoding = { "utf-16" },
	}
})

local custom_on_init = function(client)
	client.config.flags = client.config.flags or {}
	client.config.flags.allow_incremental_sync = true
end

local path = require("plenary.path")

local libraries = {
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

local custom_on_attach = function(client, bufnr)
	-- small utils to simplify mapping
	local lsp_remap = function(mode, args)
		local cmd = table.remove(args, 2)
		local key = table.remove(args, 1)

		args = args or {}
		if args.desc then
			args.desc = "[lsp] " .. args.desc
		end
		args.buffer = bufnr

		vim.keymap.set(mode, key, cmd, args)
	end
	local nmap = function(args) lsp_remap("n", args) end
	local imap = function(args) lsp_remap("i", args) end

	imap { "<C-n>", vim.lsp.buf.completion, desc = "Get completion" }

	nmap { "K", vim.lsp.buf.hover, desc = "Show hover" }
	imap { "<C-s>", vim.lsp.buf.signature_help, desc = "Show signature help" }

	nmap { "<leader>cr", vim.lsp.buf.rename, desc = "[c]ode [r]ename" }
	nmap { "<leader>ca", vim.lsp.buf.code_action, desc = "[c]ode [a]ction" }
	nmap { "<leader>cf", vim.lsp.buf.format, desc = "[c]ode [f]ormat" }

	nmap { "gd", vim.lsp.buf.definition, desc = "[g]o to [d]efinition" }
	nmap { "gD", vim.lsp.buf.declaration, desc = "[g]o to [D]eclaration" }
	nmap { "gt", vim.lsp.buf.type_definition, desc = "[g]o to [t]ype definition" }
	nmap { "gr", vim.lsp.buf.references, desc = "[g]o to [r]eferences" }
	nmap { "gi", vim.lsp.buf.implementation, desc = "[g]o to [i]mplementation" }

	local has_ts, ts = pcall(require, "sam.telescope_custom")
	if has_ts then
		nmap { "gr", ts.lsp_references, desc = "[g]o to [r]eferences under cursor" }
		nmap { "gi", ts.lsp_implementations, desc = "[g]o to [i]mplementations under cursor" }
		nmap { "<leader>ss", ts.lsp_document_symbols, desc = "[s]earch document [s]ymbols" }
		nmap { "<leader>sS", ts.lsp_workspace_symbols, desc = "search workspace [S]ymbols" }
		nmap { "<leader>st", ts.lsp_type_definitions, desc = "search workspace [S]ymbols" }

		local lib = libraries[client.name]
		if lib then
			lib = type(lib) == "function" and lib() or lib
			if lib then
				nmap { "<leader>sl", ts.make_find_in_path("Find in library", lib), desc = "[s]earch lang [l]ibrary" }
			end
		end
	end

	vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"

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

	local ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
	if ft == "typescript" or ft == "lua" then
		client.server_capabilities.semanticTokensProvider = nil
	end
end

local setup_lsp_server = function(server, config)
	if not config then
		log.err("Missing config for server " .. server)
		return
	end

	config = vim.tbl_deep_extend("force", {
		on_attach = custom_on_attach,
		on_init = custom_on_init,
		capabilities = custom_capabilities,
	}, config)

	require("lspconfig")[server].setup(config)
end

return {
	setup_all = function()
		for server, config in pairs(lsp_servers) do
			setup_lsp_server(server, config)
		end
	end,

	get_ensure_installed = function()
		local installed = {}
		local ignore = { "gdscript", "zls" }
		for server, _ in pairs(lsp_servers) do
			if not vim.tbl_contains(ignore, server) then
				table.insert(installed, server)
			end
		end
		return installed
	end,
}
