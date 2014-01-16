local fiber = require('fiber')
local await = require('fiber').await
local wait = require('fiber').wait
local urlcode = require('kylin.urlcode')

local maxinput = 1024 * 1024 * 16

local function readPost(req)
	return function (callback)
		req.post = {}
		-- get the "total" size of the incoming data
		local inputsize = tonumber(req.headers['content-length']) or 0
		if inputsize > maxinput then
			repeat
				local chunk = await(req.body.read())
			until not chunk

			callback(string.format("Total size of incoming data (%d KB) exceeds configured maximum (%d KB)",
			inputsize /1024, maxinput / 1024))
		else
			local parts = {}
			repeat
				local chunk = await(req.body.read())
				if chunk then
					table.insert(parts, chunk)
				end
			until not chunk
			local posts = table.concat(parts)
			urlcode.parsequery(posts, req.post)
			callback()
		end
	end
end

return function(app)
	return function (req, res)
		if req.method == 'POST' then
			fiber.new(function()
				local err = wait(readPost(req))
				print(err)
				if not err then
					app(req, function(code, headers, body)
						res(code, headers, body)
					end)
				else
					require('kylin.http').error(err)(req, res)
				end
			end)(function (err)
				if err then
					res(500, {
						["Content-Type"] = "text/plain"
					}, err)
				end
			end)
		else
			app(req, function(code, headers, body)
				res(code, headers, body)
			end)
		end
	end
end
