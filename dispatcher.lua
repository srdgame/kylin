
local wait = require('fiber').wait
local fs = require('uv').fs
local http = require('kylin.http')
local mvc = require('kylin.mvc')
local sendFile = require('send').file
local config = require('kylin.config')()
local logc = require('logging.console')()

local _M = {}

local class = {}

function class:dispatch(req, res) 
	mvc.handle(self.root or ".", req, res)
end

local function new(root)
	return setmetatable({root = root}, {__index = class})
end

local function redirect2App(req, res)
	local url = '/admin'
	if config.default_app then
		url = '/'..config.default_app..'/'
	end
	return http.redirect(url)(req, res)
end

local function appEnable(app)
	if app == 'admin' then
		return true -- admin is always enabled
	end
	print(config.apps())
	return config.apps()[app]
end

_M.get = function(req, res)
	-- accessing the root
	if not req.url.path or req.url.path == '/' then
		return redirect2App(req, res)
	end

	-- accessing the <host>/hello
	local root, apath = req.url.path:match('^/([^/]+)(/?.-)$')
	if not root then
		return redirect2App(req, res)
	end

	-- check the enable/disable
	if not appEnable(root) then
		return res(404, {}, {})
	end

	if not apath or string.len(apath) == 0 then
		return http.redirect('/'..root..'/')(req, res)
	end

	if apath:match('^/session') then
		return res(403, {}, {})
	end

	if apath:match('^/static/') or apath:match('^/upload/') then
		local path = "app/"..req.url.path
		local err, stat = wait(fs.stat(path))
		if stat and stat.is_file then
			sendFile(path, req, res)
		else
			res(404, {}, {})
		end
	else
		req.url.path = apath
		req.url.app = root
		local dispatcher = new('app/'..root)
		dispatcher:dispatch(req, res)
	end
end

--[[
_M.post = function(req, res)
end
]]--
_M.post = _M.get

_M.put = function(req, res)
end

_M.delete = function(req, res)
end

_M.websocket = function(req, res)
end



return _M
