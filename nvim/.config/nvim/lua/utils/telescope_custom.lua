--[[ Telescope builtin customisation ]]

local ok, _ = pcall(require, "telescope")
assert(ok, "telescope not found")

local tsbuiltin = require("telescope.builtin")
local tsthemes = require("telescope.themes")

-- layouts

local dropdown = {}
dropdown.preview = tsthemes.get_dropdown {
	winblend = 5,
	previewer = true,
	border = true,
	shorten_path = true,
	layout_config = {
		width = 0.5,
	},
}
dropdown.no_preview = vim.deepcopy(dropdown.preview)
dropdown.no_preview.previewer = false

-- custom replacements for telescope builtins

local MTS = {}

MTS.current_buffer_fuzzy_find = function()
	tsbuiltin.current_buffer_fuzzy_find(dropdown.no_preview)
end

MTS.help_tags = function()
	tsbuiltin.help_tags(tsthemes.get_ivy {
		show_version = true,
		layout_config = {
			height = 35,
		}
	})
end

MTS.find_files = function()
	tsbuiltin.find_files {
		sorting_strategy = "descending",
		scroll_strategy = "cycle",
		hidden = true,
	}
end

MTS.git_files = function()
	local path = vim.fn.expand("%:h")
	if path == "" then
		path = nil
	end

	tsbuiltin.git_files(dropdown.preview)
end

MTS.git_commits = function()
	tsbuiltin.git_commits(dropdown.preview)
end

MTS.git_branches = function()
	tsbuiltin.git_branches(dropdown.no_preview)
end

MTS.grep_string = function()
	tsbuiltin.grep_string()
end

MTS.nvim_config = function()
	tsbuiltin.find_files {
		cwd = vim.fn.stdpath("config")
	}
end

MTS.plugin_files = function()
	tsbuiltin.find_files {
		cwd = vim.fn.stdpath("data") .. "/lazy/",
	}
end

MTS.lsp_workspace_symbols = function()
	tsbuiltin.lsp_workspace_symbols {
		symbol_width = 45,
		shorten_path = true,
	}
end

MTS.lsp_document_symbols = function()
	tsbuiltin.lsp_document_symbols {
		symbol_width = 45,
		shorten_path = true,
	}
end

return setmetatable({}, {
	__index = function(_, k)
		return MTS[k] or tsbuiltin[k]
	end
})
