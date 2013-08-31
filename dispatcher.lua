
local wait = require('fiber').wait
local fs = require('uv').fs
local http = require('http')
local eval = require('eval')
local mvc = require('mvc')

local _M = {}

local class = {}

function class:dispatch(req, res) 
    -- get the lua file first
	--[[
	local path = (self.root or ".")..req.url.path..".lua"
	local err, stat = wait(fs.stat(path))
	if stat and stat.is_file then
		eval.file(path, req, res)
	else
		http.redirect('/404')(req, res)
	end
	]]--
	if not mvc.handle(self.root or ".", req, res) then
		http.redirect('/404')(req, res)
	end
end

function _M.new(root)
	return setmetatable({root = root}, {__index = class})
end

return _M
