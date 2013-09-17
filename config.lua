
local wait = require('fiber').wait
local await = require('fiber').await
local fs = require('uv').fs

local _M = {}

local apps = {}
local settings = {}

local init = function()
	apps = loadfile('./conf/apps.conf')()
	settings = loadfile('./conf/kylin.conf')()
end

_M.apps = function()
	return apps
end

_M.settings = function()
	return settings
end

_M.save = function()
	
	local err, fd = wait(fs.open('./conf/apps.conf', 'w+'))
	if not fd then
		return false, err
	end

	local r = await(fs.write(fd, 'return {\n'))
	for k, v in pairs(apps) do
		if v then
			r = await(fs.write(fd, '\t'..k..' = true,\n'))
		else
			r = await(fs.write(fd, '\t'..k..' = false,\n'))
		end
	end
	r = await(fs.write(fd, '}\n'))
end

init()

return function() 
	return _M
end
