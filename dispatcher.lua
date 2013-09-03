
local wait = require('fiber').wait
local fs = require('uv').fs
local http = require('kylin.http')
local mvc = require('kylin.mvc')
local sendFile = require('send').file
local config = require('kylin.config')()

local _M = {}

local class = {}

function class:dispatch(req, res) 
	if not mvc.handle(self.root or ".", req, res) then
		http.redirect('/404')(req, res)
	end
end

local function new(root)
	return setmetatable({root = root}, {__index = class})
end

_M.get = function(req, res)
	if not req.url.path or req.url.path == '/' then
		if config.default_app then
			req.url.path = '/'..config.default_app
		else
			req.url.path = '/admin/'
		end
	end

	local root, apath = req.url.path:match('^/([^/]+)(/?.-)$')
	if not root then
		if config.default_app then
			root = config.default_app
		else
			root = 'admin'
		end
		apatch = '/'
	end

	if apath:match('^/static/') or apath:match('^/upload/') then
		local path = "."..req.url.path
		local err, stat = wait(fs.stat(path))
		if stat and stat.is_file then
			sendFile(path, req, res)
		else
			http.redirect('/404')(req, res)
		end
	else
		req.url.path = apath
		local dispatcher = new('app/'..root)
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
