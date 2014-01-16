local fiber = require('fiber')
local await = require('fiber').await
local wait = require('fiber').wait
local urlcode = require('kylin.urlcode')
local logc = require('logging.console')()

local function readPost(req)
	return function (callback)
		local parts = {}
		repeat
			local chunk = await(req.body.read())
			if chunk then
				print(chunk)
				table.insert(parts, chunk)
			end
		until not chunk
		local posts = table.concat(parts)
		req.post = {}
		urlcode.parsequery(posts, req.post)
		callback()
	end
end

return function(app)
	return function (req, res)
		if req.method == 'POST' then
			fiber.new(function()
				wait(readPost(req))
			end)(function (err)
				if err then
					res(500, {
						["Content-Type"] = "text/plain"
					}, err)
				end
			end)
		end

		app(req, function(code, headers, body)
			res(code, headers, body)
		end)
	end
end
