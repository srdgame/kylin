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
		utils.enumfiles(root, "%.lua$", files, true)
		callback()
	end)

	files = match(files, path)

	await(function(callback) 
		for k,v in pairs(files) do 
--		    print('loading model:', v)
			--local m = loadfile(v, nil, env)
			local m, err = loadfile(v)
			if not m then
				print('ERROR WHEN LOADING MODULE '..v, err)
			end
			local t = m(env)
			if t then
				for k, v in pairs(t) do
					env[k] = v
				end
			end
		end
		callback()
	end)
end

return {
	load = loadModels,
}
