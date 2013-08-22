
local _M = {}

local admin = require ('kylin.admin')
local config = require('kylin.config')()

local app = require ('kylin.app')

local app_objs = {}

_M.load = function(web)
	local apps = config.apps()
	for path, enable in pairs(apps) do
		if enable then
			local url_path = "app/"..path
			local obj = app.new(url_path)
			web:get('^/'..url_path, function(req, res) return obj:get(req, res) end )
			web:post('^/'..url_path, function(req, res) return obj:post(req, res) end )
			web:put('^/'..url_path, function(req, res) return obj:put(req, res) end )
			web:delete('^/'..url_path, function(req, res) return obj:delete(req, res) end )
			web:websocket('^/'..url_path, function(req, res) return obj:websocket(req, res) end )
			app_objs[path] = obj
		end
	end

	web:get('^/', admin.get)
	web:post('^/', admin.post)
	web:put('^/', admin.put)
	web:delete('^/', admin.delete)
	web:websocket('^/', admin.websocket)
end

return _M

