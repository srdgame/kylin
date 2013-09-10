
local wait = require('fiber').wait
local await = require('fiber').await
local fs = require('uv').fs
local getType = require('mime').getType
local http = require('kylin.http')
local html = require('kylin.html')
local logc = require('logging.console')()
local view = require('kylin.view')
local model = require('kylin.model')
local utils = require('kylin.utils')

local _M = {}

-- return 
-- 1. whether there is an controller
-- 2. whether need to go through the models and views
local function runController(cpath, func, env)
	local f, err = loadfile(cpath, nil, env)
	if not f then
		logc:error(err)
		return false, err
	else
		local obj = f()
		if obj[func] then
			local re, info = obj[func]()
			if type(re) == 'string' then
				env.out(re)
				return true, false
			elseif type(re) == 'table' then
				for k, v in pairs(re) do
					env[k] = v
				end
				return true, true
			else
				return true, false
			end
		else
			return false, "no such method"
		end
	end
	return true, true
end

local function sendFile(root, req, res)
	--[[
	logc:info('REQ----------------------------------')
	logc:info(req)
	logc:info('-------------------------------------')
	]]--
	local file, func = utils.parsePath(req.url.path)
	local cpath = root.."/controller"..file..".lua"
	local mpath = root..'/model'..file

	local vsub = file == '/index' and '/' or file..'/'
	local vpath = root..'/view'..vsub..func..'.html'

	logc:debug({ file = file, func = func, controller = cpath, model = mpath, vsub = vsub, view = vpath})
	local err, stat = wait(fs.stat(cpath))
	if stat and stat.is_file then
		local body = {}
		local headers = {}
		local env = {}
		env = {
			__aburl = vsub, -- for relative path
			redirect = function(...)
				return http.redirect(...)(req, res)
			end,
			print = function(...) 
				logc:debug(table.concat({...}, '\t'))
			end,
			err = function(...)
				logc:error(table.concat({...}, '\t'))
			end,
			out = function(...)
				body[#body + 1] = table.concat({...}, '\t')
			end,
			header = function(key, val)
				headers[key] = val
			end,
			cookies = req.cookies,
			status = 200,
			req = req,
			res = res,
		}

		html.initHelper(env, req.url.app, root)

		model.load(root..'/model', mpath, env)

		local r, need_view = runController(cpath, func, env)
		if not r then
			return false
		end

		if need_view then
			headers['Content-type'] = 'text/html; charset=utf-8'
			local r = view.layout(vpath, env)
			if not r then
				view.layout(root..'/view/default.html', env)
			end
		end
		res(200, headers, body)
		return true
	end
	return false
end



function _M.handle(root, req, res)
	local r, info = sendFile(root, req, res)
	if not r then
		if not req.url.path:match('/$') then
			req.url.path = req.url.path..'/'
			local file, func = utils.parsePath(req.url.path)
			local cpath = root.."/controller"..file..".lua"
			local err, stat = wait(fs.stat(cpath))
			if stat and stat.is_file then
				http.redirect('/'..req.url.app..req.url.path)(req, res)
			end
		else
			logc:error(info)
			res(404, {}, {})
		end
	end
end

return _M
