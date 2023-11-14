local M = {}

local is_registered = false

M.setup = function()
	local has_cmp, cmp = pcall(require, 'cmp')
	if not has_cmp then
		return
	end

	if is_registered then
		return
	end
	is_registered = true

	local source = {}

	source.new = function()
		return setmetatable({}, { __index = source })
	end

	source.complete = function(self, params, callback)
		vim.fn['copilot#Complete'](function(result)
			callback({
				isIncomplete = true,
				items = vim.tbl_map(function(item)
					local prefix = string.sub(
						params.context.cursor_before_line, item.range.start.character + 1, item.position.character)
					return {
						label = prefix .. item.displayText,
						textEdit = {
							range = item.range,
							newText = item.text,
						},
						documentation = {
							kind = 'markdown',
							value = table.concat({
								'```' .. vim.api.nvim_buf_get_option(0, 'filetype'),
								self:deindent(item.text),
								'```'
							}, '\n'),
						}
					}
					end, (result or {}).completions or {})
			})
			end, function()
				callback({
					isIncomplete = true,
					items = {},
				})
		end)
	end

	source.deindent = function(_, text)
		local indent = string.match(text, '^%s*')
		if not indent then
			return text
		end
		return string.gsub(string.gsub(text, '^' .. indent, ''), '\n' .. indent, '\n')
	end

	function source:get_keyword_pattern()
		return '.'
	end

	source.get_trigger_characters = function()
		return {'.'}
	end

	cmp.register_source('copilot', source.new())
end

return M

