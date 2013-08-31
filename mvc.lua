
local wait = require('fiber').wait
local await = require('fiber').await
local fs = require('uv').fs
local getType = require('mime').getType
local http = require('http')
local logc = require('logging.console')()

local _M = {}

local function out (s, i, f)
	s = string.sub(s, i, f or -1)
	if s == "" then return s end
	-- we could use `%q' here, but this way we have better control
	s = string.gsub(s, "([\\\n\'])", "\\%1")
	-- substitute '\r' by '\'+'r' and let `loadstring' reconstruct it
	s = string.gsub(s, "\r", "\\r")
	return string.format(" %s('%s'); ", "out", s)
end

local function translate(s)
	s = string.gsub(s, "^#![^\n]+\n", "")
	s = string.gsub(s, "<%%(.-)%%>", "<?lua %1 ?>")
	local res = {}
	local start = 1   -- start of untranslated part in `s'
	while true do
		local ip, fp, target, exp, code = string.find(s, "<%?(%w*)[ \t]*(=?)(.-)%?>", start)
		if not ip then break end
		table.insert(res, out(s, start, ip-1))
		if target ~= "" and target ~= "lua" then
			-- not for Lua; pass whole instruction to the output
			table.insert(res, out(s, ip, fp))
		else
			if exp == "=" then   -- expression?
				table.insert(res, string.format(" %s(%s);", 'out', code))
			else  -- command
				table.insert(res, string.format(" %s ", code))
			end
		end
		start = fp + 1
	end
	table.insert(res, out(s, start))
	return table.concat(res)
end

local function layout(path, env)
	local err, fd = wait(fs.open(path, "r"))
	if not fd then
		return false, 'no layout file'
	end

	local topass = {}
	-- Stream the file to the browser
	repeat
		local chunk = await(fs.read(fd, 1024))
		if #chunk == 0 then
			chunk = nil
		end
		await(function(callback) 
			table.insert(topass, chunk)
			callback()
		end)
	until not chunk
	wait(function(callback)
		--
		local s = table.concat(topass)
		s = translate(s)
		local f, err = load(s, nil, nil, env)
		if f then
			f()
		else
			logc:error(err)
		end
		callback()
	end)
	return true
end

local function parsePath(path)
	if path:match('/$') then
		return path..'index', 'index'
	end

	--local file, func = req.url.path:match("(.-)/(%w+)")
	local file, func = path:match("(.-)[/]?([^/]+)$")
	file = file or ""
	if string.len(file) == 0 then
		file = '/index'
	end

	return file, func
end

local function sendFile(root, req, res)
	logc:info(req)
	local file, func = parsePath(req.url.path)
	local cpath = root.."/controller"..file..".lua"
--	local mpath = root..'/model'..file..'.lua'
	local vpath = root..'/view'..file..'.html'
	logc:debug(cpath, func)
	local err, stat = wait(fs.stat(cpath))
	if stat and stat.is_file then
		local body = {}
		local headers = {}
		local env = { 
			http = http,
			print = function(...) 
				logc:debug({...})
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

		local f, err = loadfile(cpath, nil, env)
		if not f then
			logc:error(err)
			return false
		else
			local obj = f()
			if obj[func] then
				local re = obj[func]()
				for k, v in pairs(re) do
					env[k] = v
				end
			else
				logc:error("not such method")
				return false
			end
		end

		--[[
		local f, err = loadfile(mpath, nil, env)
		if f then
			-- load model
		end
		--]]
		layout(vpath, env)
		res(200, headers, body)
		return true
	end
	return false
end



function _M.handle(root, req, res)
	return sendFile(root, req, res)
end

return _M
