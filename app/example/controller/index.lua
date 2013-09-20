local function index(req, res)
	local vars = {}
	vars.a = 11 
	vars.b = 12
	vars.c = 13
    vars.d = 99

	return {messages = {"hello world"}, vars = vars}
end

return {
	index = index,
}
