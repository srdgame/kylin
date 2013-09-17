local function index()
	if not req.session.data then
		return redirect(URL('login'))
	end

	local apps = app.enum()

	return { apps = apps }
end

local function enum()
	local apps = app.enum()
	return { apps = apps }
end

local function enable()
	if req.method == 'GET' then
		if req.url.query and req.url.query.app then
			app.enable(req.url.query.app, true)
		end
	end
	redirect('.');
end

local function disable()
	if req.method == 'GET' then
		if req.url.query and req.url.query.app then
			app.enable(req.url.query.app, false)
		end
	end
	redirect('.');
end

return {
	index = index,
	hello = function () return "hello world\n" end,
	about = function () redirect('hello') end,
	enum  = enum,
	enable = enable,
	disable = disable,
}
