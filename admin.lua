--
local sendFile = require('send').file
local wait = require('fiber').wait
local fs = require('uv').fs
local http = require('http')
local dispatcher = require('dispatcher').new('admin')

local _M = {}

_M.get = function(req, res)
	if req.url.path:match('^/static/') or req.url.path:match('^/upload/') then
		local path = "."..req.url.path
		local err, stat = wait(fs.stat(path))
		if stat and stat.is_file then
			sendFile(path, req, res)
		else
			http.redirect('/404')(req, res)
		end
	else
		dispatcher:dispatch(req, res)
	end
end

_M.post = function(req, res)
end

_M.put = function(req, res)
end

_M.delete = function(req, res)
end

_M.websocket = function(req, res)
end

return _M

