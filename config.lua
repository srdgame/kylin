
local wait = require('fiber').wait
local await = require('fiber').await
local fs = require('uv').fs

local _M = {}

local apps = {}
local settings = {}

local init = function()
	apps = loadfile('./conf/apps.conf')()
	settings = loadfile('./conf/kylin.conf')()
end

_M.apps = function()
	return apps
end

_M.settings = function()
	return settings
end

local function save_table_to_conf(file, t)
	
	local err, fd = wait(fs.open(file, 'w+'))
	if not fd then
		return false, err
	end

	local r = await(fs.write(fd, 'return {\n'))

	function save_t(t, tab_count) 
		tab_count = tab_count or 1
		for k, v in pairs(t) do

			function f()
				for _ = 1, tab_count do
					r = await(fs.write(fd, '\t'))
				end
			end

			if type(v) == 'number' or type(v) == 'boolean' then
				f()
				r = await(fs.write(fd, tostring(k)..' = '..tostring(v)..',\n'))
			elseif type(v) == 'string' then
				f()
				r = await(fs.write(fd, tostring(k)..' = "'..tostring(v)..'",\n'))
			elseif type(v) == 'table' then
				f()
				r = await(fs.write(fd, tostring(k)..' = {\n '))
				save_t(v, tab_count + 1)

				for _ = 1, tab_count do
					r = await(fs.write(fd, '\t'))
				end
				r = await(fs.write(fd, '},\n'))
			end
		end
	end
	save_t(t)
	r = await(fs.write(fd, '}\n'))
	wait(fs.close(fd))

end

_M.save = function()
	
	--[[
	local err, fd = wait(fs.open('./conf/apps.conf', 'w+'))
	if not fd then
		return false, err
	end

	local r = await(fs.write(fd, 'return {\n'))
	for k, v in pairs(apps) do
		if k ~= 'admin' then
			if v then
				r = await(fs.write(fd, '\t'..k..' = true,\n'))
			else
				r = await(fs.write(fd, '\t'..k..' = false,\n'))
			end
		end
	end
	r = await(fs.write(fd, '}\n'))
	wait(fs.close(fd))
	]]--
	save_table_to_conf('./conf/apps.conf', apps)
	save_table_to_conf('./conf/kylin.conf', settings)
end

init()

return function() 
	return _M
end
