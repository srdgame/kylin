
local _M = {}

local apps = {}
local settings = {}

_M.init = function()
	apps = loadfile('./conf/apps.conf')()
	settings = loadfile('./conf/kylin.conf')()
end

_M.apps = function()
	return apps
end

_M.settings = function()
	return settings
end

return function() 
	_M.init()
	return _M
end
