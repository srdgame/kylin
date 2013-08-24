
local wait = require('fiber').wait
local fs = require('uv').fs
local http = require('http')
local eval = require('eval')

local _M = {}

local class = {}

function class:dispatch(req, res, func) 
	-- get the lua file first
	local path = (self.root or ".")..req.url.path..".lua"
	local err, stat = wait(fs.stat(path))
	if stat and stat.is_file then
		eval.file(path, req, res)
		--[[
		res(200, 
			{["Content-Type"] = "text/html"},
			{"This page\n"})
			]]--
	else
		http.redirect('/404')(req, res)
	end
end

function _M.new(root)
	return setmetatable({root = root}, {__index = class})
end

return _M
