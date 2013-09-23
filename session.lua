local math = require ('math')
local cookies = require('cookies')
local logc = require('logging.console')()

local sessions = {}

local newSession = function(key, id, path, span)
	math.randomseed(os.time() + assert(tonumber(tostring({}):sub(7))))
	id = id or ('KYLIN'..math.random(0, 0xffffffff)..':'..math.random(0, 0xffffffff))
	local time = span and os.time() + span
	local session = cookies.newCookie(key, id, path, time, nil, true)
	session.data = nil
	return session
end

local loadSession = function(session)
	session.data = sessions[session.value]
end

local saveSession = function(session)
	--if session.data then
		sessions[session.value] = session.data
	--end
end

return function(app, options)
	logc:info(options)
	options = options or {}
	options.key = options.key or "kylin_session"
	options.key = options.key:lower()
	options.new = options.new or newSession
	options.load = options.load or loadSession
	options.save = options.save or saveSession
	options.expire = options.expire or 600

	return function (req, res)
		-- find and load session
		for name, value in pairs(req.cookies) do
			if name:lower() == options.key then
				req.session = value
			end
		end
		if (req.session) then
			options.load(req.session)
		else
			req.session = options.new(options.key)
		end
		req.session:update(options.expire)
		options.save(req.session)

		app(req, function(code, headers, body)
			req.cookies[options.key] = req.session
			options.save(req.session)
			res(code, headers, body)
		end)
	end
end

