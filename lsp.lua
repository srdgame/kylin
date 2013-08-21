local p = require('utils').prettyPrint
local fs = require('uv').fs
local await = require('fiber').await
local wait = require('fiber').wait
local newFiber = require('fiber').new
local newStream = require('stream').newStream
local getType = require('mime').getType
local floor = require('math').floor
local http = require('http')

local function readFile(path)
	local err, fd = wait(fs.open(path, "r"))
	if not fd then
		return nil, 'file not exist'
	end

	return function(callback)
		-- Stream the file to the browser
		local code = {}
		repeat
			local chunk = await(fs.read(fd, 10))
			if #chunk == 0 then
				chunk = nil
			end
			code[#code + 1] = chunk
		until not chunk

		callback(code)
	end
end

local function sendFile(path, req, res)
	loadfile(path)
	--[[
	local read, err = readFile(path)
	if not read then
		res(404, {}, {})
		--return nil, err
	end
	]]--
	res(200, {}, {'hello world\n'})
	return

	--[[
	read(function(code)
		local chunk = table.concat(code)
		if not chunk then
			res(404, {}, {})
		else
			local body = {}
			local env = { 
				print = function(...) 
					local t = {...}
					body[#body + 1] = table.concat(t)
				end
			}
			load(chunk, nil, nil, env)()
			res(200, {}, body)
			print('return page')
		end
	end)
	print('done')
	]]--
end

return {
  file = sendFile,
}
