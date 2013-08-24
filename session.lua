local math = require ('math')
local cookies = require('cookies')

local newSession = function(key, id, path, span)
	math.randomseed(os.time() + assert(tonumber(tostring({}):sub(7))))
	id = id or ('KYLIN'..math.random(0, 0xffffffff)..':'..math.random(0, 0xffffffff))
	local time = os.time() + (span or 600)
	return cookies.newCookie(key, id, path, time, nil, true)
end

return function(app, options)
	options = options or {}
	options.key = options.key or "kylin_session"
	options.key = options.key:lower()
	options.newSession = options.newSession or newSession

	return function (req, res)
		-- find and load session
		for name, value in pairs(req.cookies) do
			if name:lower() == options.key then
				req.session = options.newSession(options.key, value, options.path, options.span)
			end
		end
		req.session = req.session or options.newSession(options.key)

		app(req, function(code, headers, body)
			req.cookies[options.key] = req.session:tostring()
			res(code, headers, body)
		end)
	end
end

