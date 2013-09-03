
local wait = require('fiber').wait
local fs = require('uv').fs
local http = require('http')
local eval = require('eval')
local mvc = require('mvc')
local sendFile = require('send').file

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
		req.url.path = '/admin/'
	end

	local root, apath = req.url.path:match('^/([^/]+)(/?.-)$')
	if not root then
		root = 'admin'
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
