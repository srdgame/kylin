
local function login(password)
	return password == 'abc'
end

return {
	auth = {
		login = login,
	}
}
