
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
		local r, err = edit.loadFile(req.url.query.file)
		if r then
			return r
		end
		log(err)
	end
	return inerRes(401, {}, {})
end

local function save()
	if edit.saveFile(req.posts.file, req.posts.content) then
		return "File saving done"
	else
		return inerRes(500, {}, {})
	end
end

local function fm()
	if not req.url.query.app then
		return inerRes(500, {}, {})
	end
	if req.method == 'GET' then
		-- read file system
		setHeader("Content-Type", "application/json; charset=utf-8")
		--return '[{"label":"Saurischia","id":"1","children":[{"label":"Herrerasaurians","id":"2"},{"label":"Theropods","id":"3"}]}]'
		return edit.fm(req.url.query.app)	
	elseif req.method == 'POST' then
		-- write file system
	end
end

return {
	index = auth.check(index),
	editor = auth.check(editor),
	file = auth.check(file),
	save = auth.check(save),
	fm = auth.check(fm),
}

