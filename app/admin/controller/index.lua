local function index(req, res)
	if test_model then
		test_model()
	else
		print('test_model not exist')
	end
	local vars = {}
	vars.a = 11 
	vars.b = 12
	vars.c = 13

	return {messages = {"hello world"}, vars = vars}
end

return {
	index = index,
	hello = function () return "hello world\n" end,
	about = function () redirect(URL('hello')) end
}
