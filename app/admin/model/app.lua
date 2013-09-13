--- load applications 
--

local function test()
end

local function login(password)
	return password == 'abc'
end

return {test = test, login = login}
