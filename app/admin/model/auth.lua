local env = ...

local function login(password)
	return password == 'abc'
end

local function check(func)
	return function(...)
		if not env.req.session.data then
			if env.req.method == 'GET' then
				return env.redirect(env.URL('login'))
			else
				return env.inerRes(401, {}, {})
			end
		end
		return func(...)
	end
end

return {
	auth = {
		login = login,
		check = check,
	}
}
