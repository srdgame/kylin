local function index()
	if not req.session.data  then
		return redirect(URL('login'))
	end

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
	about = function () redirect('hello') end
}
