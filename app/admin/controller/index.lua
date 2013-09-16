local function index()
	if not req.session.data then
		return redirect(URL('login'))
	end

	return { messages = {"hello world"} }
end

local function enum()
	local apps = app.enum()
	return { apps = apps }
end

return {
	index = index,
	hello = function () return "hello world\n" end,
	about = function () redirect('hello') end,
	enum  = enum,
}
