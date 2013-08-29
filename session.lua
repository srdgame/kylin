local math = require ('math')
local cookies = require('cookies')

local newSession = function(key, id, path, span)
	math.randomseed(os.time() + assert(tonumber(tostring({}):sub(7))))
	id = id or ('KYLIN'..math.random(0, 0xffffffff)..':'..math.random(0, 0xffffffff))
	local time = os.time() + (span or 600)
	local session = cookies.newCookie(key, id, path, time, nil, true)
	session.data = nil
	return session
end

local loadSession = function(session)
	session.data = nil
end

local saveSession = function(session)
	-- nothing
end

return function(app, options)
	options = options or {}
	options.key = options.key or "kylin_session"
	options.key = options.key:lower()
	options.new = options.new or newSession
	options.load = options.load or loadSession
	options.save = options.save or saveSession

	return function (req, res)
		-- find and load session
		for name, value in pairs(req.cookies) do
			if name:lower() == options.key then
				req.session = options.new(options.key, value, options.path, options.span)
			end
		end
		if (req.session) then
			options.load(req.session)
			req.session:update(600)
		else
			req.session = options.new(options.key)
			options.save(req.session)
		end

		app(req, function(code, headers, body)
			req.cookies[options.key] = req.session:tostring()
			res(code, headers, body)
		end)
	end
end

