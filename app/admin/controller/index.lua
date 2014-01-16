local function index()
	local apps = app.enum()

	return { apps = apps }
end

local function enable()
--	log(req)
	if req.method == 'GET' then
		if req.query and req.query.app then
			local enable = true
			if not req.query.enable or req.query.enable == 'false' then
				enable = false
			end
			app.enable(req.query.app, enable)
		end
	end
	redirect('.');
end

local function create()
	--
	local result = false
	if req.query and req.query.app then
		if app.create(req.query.app) then
			result = true
		end
	end
	return { result = result }
end

return {
	index = auth.check(index),
	hello = function () return "hello world\n" end,
	about = function () redirect('hello') end,
	enable = auth.check(enable),
	create = auth.check(create),
}
