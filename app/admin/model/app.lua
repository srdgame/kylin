--- load applications 
--
local utils = require ('kylin.utils')
local function enum()
	local folders = utils.enumFolders('app')
	local apps = {}
	for k, v in pairs(folders) do 
		local s = string.match(v, "app/(.+)")
		table.insert(apps, s)
	end
	return apps
end

return {
	app = {
		enum = enum,
	}
}
