local mapping = {
	info = vim.log.levels.INFO,
	warn = vim.log.levels.WARNING,
	err = vim.log.levels.ERROR,
	dbg = vim.log.levels.DEBUG,
}

local t = setmetatable({}, {
	__index = function(_, lvl_name)
		local lvl = mapping[lvl_name]
		if lvl == nil then
			error("Unknown log function: "..lvl_name..". Avaialable: info, warn, err, dbg")
		end
		return function(msg)
			vim.notify(msg, lvl, {})
		end
	end
})

return t
