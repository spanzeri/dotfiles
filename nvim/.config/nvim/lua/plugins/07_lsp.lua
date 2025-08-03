return {
    -- mason: Install LSPs, linter and similar tools
    {
        "williamboman/mason.nvim",
        config = true,
    },

    -- mason-lspconfig: Bridges lspconfig and mason
    {
        "williamboman/mason-lspconfig.nvim",
        config = true,
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
    },

    {
        "folke/lazydev.nvim",
        ft = "lua",
        event = "BufEnter",
        config = true,
    },

    -- lspconfig: lsp configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/nvim-cmp",
        },

        event = "BufEnter",

        config = function()
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                    end

                    if Snacks then
                        map("gd", Snacks.picker.lsp_definitions, "[g]oto [d]efinition")
                        map("gr", Snacks.picker.lsp_references, "[g]oto [r]eferences")
                        map("gi", Snacks.picker.lsp_implementations, "[g]oto [i]mplementation")
                        map("<leader>ss", Snacks.picker.lsp_symbols, "[s]earch document [s]ymbols")
                        map("<leader>sS", Snacks.picker.lsp_workspace_symbols, "[s]earch workspace [S]ymbols")
                        map("<leader>D", Snacks.picker.lsp_type_definitions, "goto type [d]efinitions")
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
                    vim.keymap.set(
                        "i",
                        "<C-s>",
                        vim.lsp.buf.signature_help,
                        { buffer = event.buf,
                            desc = "LSP: signature help" })

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client.server_capabilities.documentHighlightProvider == true then
                        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                            buffer = event.buf,
                            callback = function()
                                pcall(vim.lsp.buf.document_highlight)
                            end,
                        })

                        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                            buffer = event.buf,
                            callback = function()
                                pcall(vim.lsp.buf.clear_references)
                            end,
                        })
                    end

                    if client then
                        vim.keymap.set(
                            { "n", "v" },
                            "<leader>cf",
                            vim.lsp.buf.format,
                            { desc = "[c]ode [f]ormat" })
                    end

                    -- Clangd extensions
                    local function on_clangd_switch_source_header(err, uri)
                        if not uri or uri == "" then
                            vim.api.nvim_echo({ { "No source/header found", "WarningMsg" } }, true, {})
                            return
                        end
                        local filename = vim.uri_to_fname(uri)
                        vim.api.nvim_cmd({
                            cmd = "edit",
                            args = { filename },
                        }, {})
                    end

                    local function clangd_switch_source_header()
                        vim.lsp.buf_request(0, "textDocument/switchSourceHeader", {
                            uri = vim.uri_from_bufnr(0),
                        }, on_clangd_switch_source_header)
                    end

                    map("<leader>co", clangd_switch_source_header, "switch source/header")
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
                        "--j=8",
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
                ["Github Copilot"] = {},
            }

            local skip_install = { "gdscript", "jails", "Github Copilot" }

            local ensure_installed = {}
            for server, _ in pairs(servers) do
                if not vim.tbl_contains(skip_install, server) then
                    table.insert(ensure_installed, server)
                end
            end

            require("mason").setup()
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

            -- Jai setup
            vim.lsp.config.jails = {
                cmd = { "jails" },
                root_markers = { "jail.json", "build.jai", "first.jai" },
                filetypes = { "jai" },
            }
            vim.lsp.enable("jails")

            -- Fix github copilot error
            vim.lsp.config["Github Copilot"] = {}
        end,
    },
}
