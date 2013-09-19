local lfs = require('lfs')
local urlcode = require('kylin.urlcode')

local function enumFiles (path, pattern, intofolder, r_table)
	r_table = r_table or {}
	if lfs.attributes(path, 'mode') ~= 'directory' then
		return r_table
	end
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path..'/'..file

			local ty = lfs.attributes (f, 'mode') 
			--print(ty, f)
			if ty == "directory" and intofolder then
				enumFiles (f, pattern, intofolder, r_table)
			else
				if ty == 'file' then
					if string.match(f, pattern) then
						table.insert(r_table, f)
					end
				end
			end
		end
	end
	return r_table
end

local function enumFolders(path, r_table)
	local r_table = r_table or {}

	if lfs.attributes(path, 'mode') ~= 'directory' then
		return r_table
	end
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path..'/'..file

			local ty = lfs.attributes (f, 'mode') 
			--print(ty, f)
			if ty == "directory"  then
				table.insert(r_table, f)
			end
		end
	end

	return r_table
end

local function parsePath(path)
	if not path or path == '/' then
		return '/index', 'index'
	end
	if path:match("/$") then
		return path:sub(1, -2), 'index'
	end

	--local file, func = req.url.path:match("(.-)/(%w+)")
	local file, func = path:match("(.-)[/]?([^/]+)$")
	file = file or ""
	if string.len(file) == 0 then
		file = '/index'
	end

	return file, func
end

return {
	enumFolders = enumFolders,
	enumFiles = enumFiles,
	parsePath = parsePath, 
}
