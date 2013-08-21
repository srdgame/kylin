
local _M = {}

local apps = {}

_M.init = function()
	apps = loadfile('./conf/apps.conf')
end

_M.apps = function()
	return apps
end

return _M
