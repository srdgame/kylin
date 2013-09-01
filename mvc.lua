
local wait = require('fiber').wait
local await = require('fiber').await
local fs = require('uv').fs
local getType = require('mime').getType
local http = require('http')
local logc = require('logging.console')()
local view = require('kylin.view')
local model = require('kylin.model')
local utils = require('kylin.utils')

local _M = {}

local function runController(cpath, func, env)
	local f, err = loadfile(cpath, nil, env)
	if not f then
		logc:error(err)
		return false
	else
		local obj = f()
		if obj[func] then
			local re = obj[func]()
			if type(re) == 'string' then
				env.out(re)
				return true
			end
			if type(re) == 'table' then
				for k, v in pairs(re) do
					env[k] = v
				end
			end
		else
			logc:error("not such method")
			return false
		end
	end
	return true, true
end
local function sendFile(root, req, res)
	logc:info(req)
	local file, func = utils.parsePath(req.url.path)
	local cpath = root.."/controller"..file..".lua"
	local mpath = root..'/model'..file
	local vpath = root..'/view'..file..'.html'
	logc:debug(cpath, func)
	local err, stat = wait(fs.stat(cpath))
	if stat and stat.is_file then
		local body = {}
		local headers = {}
		local env = { 
			http = http,
			print = function(...) 
				logc:debug(...)
			end,
			out = function(...)
				body[#body + 1] = table.concat({...}, '\t')
			end,
			headers = headers,
			cookies = req.cookies,
			status = 200,
			req = req,
			res = res,
		}

		model.load(root..'/model', mpath, env)

		local r, need_view = runController(cpath, func, env)
		if not r then
			return false
		end

		if need_view then
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
	return sendFile(root, req, res)
end

return _M
