local lfs = require('lfs')

local function enumfiles (path, pattern, r_table, intofolder)
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local f = path..'/'..file

			local ty = lfs.attributes (f, 'mode') 
			--print(ty, f)
			if ty == "directory" and intofolder then
				enumfiles (f, pattern, r_table, intofolder)
			else
				if ty == 'file' then
					if string.match(f, pattern) then
						table.insert(r_table, f)
					end
				end
			end
		end
	end
end

local function parsePath(path)
	if path:match('/$') then
		return path..'index', 'index'
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
	enumfiles = enumfiles,
	parsePath = parsePath, 
}
