--- load applications 
--
local utils = require ('kylin.utils')
local function enum()
	local folders = utils.enumFolders('app')
	for k, v in pairs(folders) do 
		print(k, v)
	end
end

return {
	app = {
		enum = enum,
	}
}
