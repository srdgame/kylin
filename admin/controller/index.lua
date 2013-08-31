local function index(req, res)
	local vars = {}
	vars.a = 11 
	vars.b = 12
	vars.c = 13

	return {messages = {"hello world"}, vars = vars}
end

return {
	index = index,
	hello = index
}
