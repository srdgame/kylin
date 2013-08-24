
local session = {}
function session:value()
	return "aaaaaaaaaaaaaa"
end

local newSession = function(req)
	return setmetatable({}, {__index = session})
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
				req.session = options.newSession(req, value)
			end
		end
		req.session = req.session or options.newSession(req)

		app(req, function(code, headers, body)
			req.cookies[options.key] = req.session:value()
			res(code, headers, body)
		end)
	end
end

