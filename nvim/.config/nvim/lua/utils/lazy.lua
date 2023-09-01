-- Utility functions
--
--  has_plugin(pname: string) - return true if the pname plugin is added to lazy
--  load_plugin_with_function(pname: string, module, funcs)
--		- pname: name of the plugin to load
--		- funcs: function (string) or functions (table) that should trigger load

local M = {}

M.has_plugin = function(name)
	local has_lazy_config, lazy_config = pcall(require, "lazy.core.config")
	return has_lazy_config and lazy_config.plugins[name] ~= nil
end

M.load_plugin_with_function = function(name, module, funcs)
	assert(name and name ~= "")
	if type(funcs) == "string" then
		funcs = { funcs }
	end

	for _, fn in ipairs(funcs) do
		local old_fn = module[fn]
		module[fn] = function(...)
			module[fn] = old_fn -- restore previous function
			require("lazy").load { plugins = { name } }
			module[fn](...)
		end
	end
end

---@param name string
---@param fn fun(name:string)
M.on_load = function(name, fn)
	local config = require("lazy.core.config")
	if config.plugins[name] and config.plugins[name]._.loaded then
		vim.schedule(function() fn(name) end)
	else
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyLoad",
			callback = function(event)
				if event.name == name then
					fn(name)
				end
			end,
		})
	end
end

return M
