
local _M = {}

local admin = require ('kylin.admin')

local app = require ('kylin.app')

_M.load = function(web, apps)
	--[[
	for path, enable in pairs(apps) do
		if enable then
			web:get('^/app/'..path, app.get)
			web:post('^/app/'..path, app.post)
			web:put('^/app/'..path, app.put)
			web:delete('^/app/'..path, app.delete)
			web:websocket('^/app/'..path, app.websocket)
		end
	end
	]]--

	web:get('^/', admin.get)
	--[[
	web:post('^/', admin.post)
	web:put('^/', admin.put)
	web:delete('^/', admin.delete)
	web:websocket('^/', admin.websocket)
	]]--
end

return _M

