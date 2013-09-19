
local function index()
	if req.url.query.app then
		return {}
	else
		return redirect('/')
	end
end

return {
	index = auth.check(index)
}
