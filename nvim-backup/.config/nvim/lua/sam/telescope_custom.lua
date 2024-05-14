local log = require("sam.logging")

local has_ts, tsbuiltin = pcall(require, "telescope.builtin")
if not has_ts then
	log.err("Telescope not found?")
	error("If we don't have telescope, we also cannot have custom functions")
end
local tsthemes = require("telescope.themes")

local custom_ts = {}

custom_ts.make_find_in_path = function(prompt, path)
	return function()
		tsbuiltin.find_files({
			cwd = path,
			prompt_title = prompt,
		})
	end
end

custom_ts.plugin_files = custom_ts.make_find_in_path("Find in plugins", vim.fn.stdpath("data") .. "/lazy/")
custom_ts.nvim_config = custom_ts.make_find_in_path("Find in nvim config", vim.fn.stdpath("config"))

custom_ts.lsp_workspace_symbols = function()
	tsbuiltin.lsp_workspace_symbols({
		symbol_width = 45,
		shorten_path = true,
	})
end

custom_ts.help_tags = function()
	tsbuiltin.help_tags(tsthemes.get_ivy({
		show_version = true,
		layout_config = {
			height = 35,
		},
	}))
end

return setmetatable({}, {
	__index = function(_, k)
		return custom_ts[k] or tsbuiltin[k]
	end
})
