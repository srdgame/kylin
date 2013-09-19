
local function index()
	if req.url.query.app then
		return { app = edit.listFiles(req.url.query.app) }
	else
		return redirect(URL(''))
	end
end

-- edit one file
local function editor()
	if req.url.query.app and req.url.query.file then
		local file_content = "function test() \\n print('thx') \\n end"
		return {file_content = file_content}
	else
		return redirect(URL(''))
	end
end

local function file()
	if req.url.query.app and req.url.query.file then
		return edit.loadFile(req.url.query.file)
	else
		return redirect(URL(''))
	end
end

local function save()
	return req.posts.content
end

return {
	index = auth.check(index),
	editor = auth.check(editor),
	file = auth.check(file),
	save = auth.check(save),
}
