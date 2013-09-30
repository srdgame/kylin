local env = ...
local config = require('kylin.config')()

local function login(password)
	local cfgpass = config.settings()['admin_pass']
	if not cfgpass then
		cfgpass = 'kylin'
	end
	return password ==  cfgpass
end

local function updatePass(orig_pass, new_pass)
	if not new_pass or string.len(new_pass) == 0 then
		return nil, 'New password could not be empty'
	end

	local cfgpass = config.settings()['admin_pass']
	if not cfgpass then
		cfgpass = 'kylin'
	end

	if orig_pass ~= cfgpass then
		return nil, 'original password incorrect'
	end

	config.settings()['admin_pass'] = new_pass
	config.save()
	return true, 'password changed!'
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
		updatePass = updatePass,
	}
}
