local env = ...

local function login(password)
	return password == 'abc'
end

local function check(func)
	return function(...)
		if not env.req.session.data then
			return env.redirect(env.URL('login'))
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
