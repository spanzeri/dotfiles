local jai_compiler_path
local jai_base_path

local search_jai_path = function(execute_on_find)
    local cmd = vim.fn.has("win32") == 1 and "where" or "which"
    vim.system({ cmd, "jai" }, { text = true }, function(result)
        if result.code == 0 then
            local path = vim.trim(result.stdout)
            if path ~= "" then
                jai_compiler_path = path
                jai_base_path = vim.fn.fnamemodify(path, ":p:h:h")
                vim.schedule(execute_on_find)
            else
                vim.notify("Jai not found in PATH", vim.log.levels.WARN)
            end
        end
    end)
end


local on_jai_found = function()
    if Snacks then
        vim.keymap.set("n", "<leader>sl", function()
            Snacks.picker.files({
                dirs = { jai_base_path },
                ft = "jai",
            })
        end, { desc = "Search Jai library" })

        vim.keymap.set("n", "<leader>sL", function()
            Snacks.picker.files({
                dirs = { jai_base_path },
            })
        end, { desc = "Search all files in Jai library" })
    end
end

-- pcall(search_jai_path, on_jai_found)
search_jai_path(on_jai_found)

