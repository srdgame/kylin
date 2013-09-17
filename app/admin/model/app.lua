--- load applications 
--
local utils = require ('kylin.utils')
local config = require ('kylin.config')()

local function enum()
	local folders = utils.enumFolders('app')
	local apps = {}
	for k, v in pairs(folders) do 
		local s = string.match(v, "app/(.+)")
		table.insert(apps, { name=s, enable = config.apps()[s] })
	end
	for k, v in pairs(apps) do
	end
	return apps
end

local function enable(app, enable)
	config.apps()[app] = enable
	config.save()
end

return {
	app = {
		enum = enum,
		enable = enable,
	}
}
