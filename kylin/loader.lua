
local _M = {}

local dispatcher = require ('kylin.dispatcher')
local config = require('kylin.config')()

local app_objs = {}

_M.load = function(web)
	web:get('^/', dispatcher.get)
	web:post('^/', dispatcher.post)
	web:put('^/', dispatcher.put)
	web:delete('^/', dispatcher.delete)
	web:websocket('^/', dispatcher.websocket)
end

return _M

