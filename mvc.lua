
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
local function runController(cpath, func, env, view)
	local f, err = loadfile(cpath, nil, env)
	if not f then
		logc:error(err)
		return false, err
	end
	local obj = f()
	if not obj[func] then
		return false, "no such method"
	end

	local need_view = true
	local re, info = obj[func]()
	if type(re) == 'string' then
		env.out(re)
		need_view = false
	elseif type(re) == 'table' then
		for k, v in pairs(re) do
			env[k] = v
		end
	end
	view(need_view)
	return true, 'mvc done'
end

local function initEnv(env)
	env.table = table
	env.pairs = pairs
	env.string = string
	env.wait = wait
	env.await = await
end

local function sendFile(root, req, res)
	local file, func = utils.parsePath(req.url.path)
	local cpath = root.."/controller"..file..".lua"
	local mpath = root..'/model'..file

	local vsub = file == '/index' and '/' or file..'/'
	local vpath = root..'/view'..vsub..func..'.html'

	--logc:debug({ file = file, func = func, controller = cpath, model = mpath, vsub = vsub, view = vpath})
	local err, stat = wait(fs.stat(cpath))
	if stat and stat.is_file then
		local body = {}
		local headers = {}
		local env = {}
		local inter_res = false
		env = {
			__aburl = vsub, -- for relative path
			redirect = function(...)
				http.redirect(...)(req, res)
				inter_res = true
			end,
			log = function(obj)
				logc:debug(obj)
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
			urlcode = require('kylin.urlcode'),
			status = 200,
			req = req,
			res = res,
		}
		initEnv(env)

		html.initHelper(env, req.url.app, root)

		model.load(root..'/model', mpath, env)

		return runController(cpath, func, env, function (need_view) 
			if inter_res then
				return
			end
			if need_view then
				headers['Content-type'] = 'text/html; charset=utf-8'
				local r = view.layout(vpath, env)
				if not r then
					r = view.layout(root..'/view/default.html', env)
				end
				if not r then
					logc:error('failed to load view for '..req.url.app..req.url.path)
				end
			end
			print(200, #body)
			res(200, headers, body)
		end)
	else
		return false
	end
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
				return
			end
		end
		logc:error(info)
		res(404, {}, {})
	end
end

return _M
