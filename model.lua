local await = require('fiber').await
local utils = require('kylin.utils')

local function match(files, path)
	local t = {}
	for k, v in pairs(files) do
		local p = '^'..utils.parsePath(v)
		--print(v, p, path)
		if string.match(path, p) then
			table.insert(t, v)
		end
	end
	return t
end

local function loadModels(root, path, env)
	--print('loadModels', root)
	local files = {}
	await(function(callback)
		utils.enumfiles(root, "%.lua", files, true)
		callback()
	end)

	files = match(files, path)

	await(function(callback) 
		for k,v in pairs(files) do 
		    print(k,v)
			local m = loadfile(v, nil, env)
			m()
		end
		callback()
	end)
end

return {
	load = loadModels,
}
