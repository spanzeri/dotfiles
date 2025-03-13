return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "williamboman/mason.nvim",
                build = ":MasonUpdate",
                config = true,
            },
            "williamboman/mason-lspconfig.nvim",
            {
                "WhoIsSethDaniel/mason-tool-installer.nvim",
                opts = {
                    auto_update = true,
                    debounce_hours = 24,
                },
            },
            { "folke/neodev.nvim", opts = {} },
            -- { 'saghen/blink.cmp' },
            { "hrsh7th/nvim-cmp" },
        },

        event = "BufEnter",

        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    local has_ts, tsbuiltin = pcall(require, "telescope.builtin")
                    if has_ts then
                        map("gd", tsbuiltin.lsp_definitions, "[g]oto [d]efinition")
                        map("gr", tsbuiltin.lsp_references, "[g]oto [r]eferences")
                        map("gi", tsbuiltin.lsp_implementations, "[g]oto [i]mplementation")
                        map("<leader>ss", tsbuiltin.lsp_document_symbols, "[s]earch document [s]ymbols")
                        map("<leader>sS", tsbuiltin.lsp_dynamic_workspace_symbols, "[s]earch workspace [S]ymbols")
                        map("<leader>D", tsbuiltin.lsp_type_definitions, "goto type [d]efinitions")
                    end
                    map("gD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")

                    map("<leader>cr", vim.lsp.buf.rename, "[c]ode [r]ename")

                    local has_wk, wk = pcall(require, "which-key")
                    if has_wk then
                        wk.add({ "<leader>c", group = "code" })
                    end

                    map("<leader>ca", vim.lsp.buf.code_action, "[c]ode [a]ction")

                    map("K", vim.lsp.buf.hover, "hover documentation")
                    map("S", vim.lsp.buf.signature_help, "[S]ignature help")
                    vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, { buffer = event.buf, desc = "LSP: signature help" })

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider == true then
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            callback = vim.lsp.buf.clear_references,
                        })
                    end
                end,
            })

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local has_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
            if has_cmp_lsp then
                capabilities = vim.tbl_deep_extend("force", capabilities, cmp_lsp.default_capabilities())
            end
            local has_blink, blink_cmp = pcall(require, "blink.cmp")
            if has_blink then
                capabilities = blink_cmp.get_lsp_capabilities(capabilities)
            end

            capabilities.textDocument.completion.completionItem.snippetSupport = true

            -- Fix compatibility issues with copilot
            capabilities = vim.tbl_deep_extend("force", capabilities, {
                offsetEncoding = { "utf-16" },
                general = { positionEncoding = { "utf-16" } },
            })

            local servers = {
                bashls = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = { checkThirdParty = false },
                            telemetry = { enable = false },
                            completion = { callSnippet = "Replace" },
                            diagnostics = { disable = { "missing-fields" } },
                        },
                    },
                },
                jsonls = {
                    settings = {
                        json = { validate = { enable = true } },
                    },
                },
                cmake = (vim.fn.executable("cmake-language-server") == 1) and {} or nil,
                clangd = {
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--j=4",
                        "--suggest-missing-includes",
                        "--clang-tidy",
                        "--clang-tidy-checks=performance-*,bugprone-*",
                        "--all-scopes-completion",
                        "--completion-style=detailed",
                        "--header-insertion=iwyu",
                        "--pretty",
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
            }

            local skip_install = { "gdscript" }

            local ensure_installed = {}
            for server, _ in pairs(servers) do
                if not vim.tbl_contains(skip_install, server) then
                    table.insert(ensure_installed, server)
                end
            end


            require("mason").setup()
            require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
            require("mason-lspconfig").setup({
                automatic_installation = true,
                handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        vim.notify("Setting up LSP server: " .. server_name, vim.log.levels.INFO)
                        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                        require("lspconfig")[server_name].setup(server)
                    end
                },
            })
        end
    }
}
