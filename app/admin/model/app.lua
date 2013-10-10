--- load applications 
--
local utils = require ('kylin.utils')
local config = require ('kylin.config')()
local wait = require ('fiber').wait

local function enum()
	local folders = utils.enumFolders('app')
	local apps = {}
	for k, v in pairs(folders) do 
		local s = string.match(v, "app/(.+)")
		table.insert(apps, { name=s, enable = config.apps()[s] })
	end
	--[[
	for k, v in pairs(apps) do
		print(k, v.name)
	end
	]]
	return apps
end

local function enable(app, enable)
	config.apps()[app] = enable
	config.save()
end

local function create(app)
	local fs = require('uv').fs
	local path = 'app/'..app

	local err, stat = wait(fs.stat(path))
	---if stat and stat.is_directory then
	if stat then
		return false
	end

	utils.mkdir(path)
	utils.mkdir(path..'/controller')
	utils.mkdir(path..'/view')
	utils.mkdir(path..'/model')
	utils.mkdir(path..'/static')
	utils.mkdir(path..'/static/images')
	utils.mkdir(path..'/static/css')
	utils.mkdir(path..'/static/js')

	return true

end

return {
	app = {
		enum = enum,
		enable = enable,
		create = create,
	}
}
