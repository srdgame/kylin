local utils = require ('kylin.utils')
local wait = require('fiber').wait
local await = require('fiber').await
local fs = require('uv').fs
local json = require ('json')
local logc = require ('logging.console')()

local function listFiles(app)
	local controllers = utils.enumFiles('app/'..app..'/controller', "%.lua$", true)
	local models = utils.enumFiles('app/'..app..'/model', "%.lua$", true)
	local views = utils.enumFiles('app/'..app..'/view', "%.html$", true)
	local statics = utils.enumFiles('app/'..app..'/static', ".+", true)
	return {
		controllers = controllers,
		models = models,
		views = views,
		statics = statics,
	}
end

local function loadFile(path)
	local err, fd = wait(fs.open(path, "r"))
	if not fd then
		return nil, 'file not exist'
	end

	local content = {}
	repeat
		local chunk = await(fs.read(fd, 100))
		if #chunk == 0 then
			chunk = nil
		end
		table.insert(content, chunk)
	until not chunk

	fs.close(fd)

	return table.concat(content)
end

local function saveFile(path, content)
	print(path, content)
	local err, fd = wait(fs.open(path, "w"))
	if not fd then
		return nil, 'file not exist'
	end

	local r = await(fs.write(fd, content))
	fs.close(fd)

	return r
end

local function convert_to_json(files)
	local r_table = {
		label = files.name,
		id = files.path,
		type = files.type,
		children = {},
	}
	if files.childs and #files.childs ~= 0 then
		for k, v in pairs(files.childs) do
			table.insert(r_table.children, convert_to_json(v))
		end
	end
	return r_table
end

local function fm(app)
	--[[
	local file = {}
	table.insert(file, {
		label = "root",
		id = "root",
		type = "folder",
		children = {
			{
				label = "child1",
				id = "c1",
				type = 'file',
				children = {
					label = "child3",
					id = "c4",
					type = "folder",
				},
				{
					label = "child2",
					id = "abc",
					type = 'folder',
				},
			},
			{
				label = "child2",
				id = "abc",
				type = 'folder',
			},
		},
	})]]--

	local rtable = {name="root", type="root", path=app, childs = {}}
	utils.enumPath('app/'..app, rtable.childs)
	local t = convert_to_json(rtable)
	t1 = {}
	table.insert(t1, t)

	--logc:info(t1)
	--logc:info(file)
	
	return json.encode(t1)
	--return json.encode(file)
end

return {
	edit = {
		listFiles = listFiles,
		loadFile = loadFile,
		saveFile = saveFile,
		fm = fm,
	}
}
