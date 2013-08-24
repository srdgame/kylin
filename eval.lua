local fs = require('uv').fs
local getType = require('mime').getType
local http = require('http')
local logc = require('logging.console')()

local function sendFile(path, req, res)
	logc:info(req)
	local body = {}
	local headers = {}
	local env = { 
		http = http,
		print = function(...) 
			logc:debug({...})
		end,
		html = function(...)
			body[#body + 1] = table.concat({...}, '\t')
		end,
		body = body,
		headers = headers,
		cookies = {},
		status = 200,
	}
	local f, err = loadfile(path, nil, env)
	if not f then
		logc:error(err)
		res(404, {}, {err})
	else
		f() -- execute page
		res(200, headers, body)
	end
end

return {
  file = sendFile,
}
