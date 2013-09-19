local utils = require ('kylin.utils')
local wait = require('fiber').wait
local await = require('fiber').await
local fs = require('uv').fs

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

  return table.concat(content)
end

return {
	edit = {
		listFiles = listFiles,
		loadFile = loadFile,
	}
}
