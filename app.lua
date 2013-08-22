--
local sendFile = require('send').file
local wait = require('fiber').wait
local fs = require('uv').fs
local http = require('http')
local config = require('kylin.config')()

local class = {}

function class:get(req, res)
	if req.url.path:match('^/'..self.path..'/static/') or req.url.path:match('^/'..self.path..'/upload/') then
		local path = "."..req.url.path
		local err, stat = wait(fs.stat(path))
		if stat and stat.is_file then
			sendFile(path, req, res)
		else
			http.redirect('/404')(req, res)
		end
	else
		self.dispatcher:dispatch(req, res)
	end
end

function class:post(req, res)
end

function class:put(req, res)
end

function class:delete(req, res)
end

function class:websocket(req, res)
end

local _M = {}
_M.new = function(path)
	local settings = config.settings()
	local root = settings.root or "."
	local dispatcher = require('dispatcher').new(root)
	return setmetatable({dispatcher = dispatcher, path = path}, {__index = class})
end

return _M
