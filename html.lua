local urlcode = require('kylin.urlcode')
local _M = {}

local __all__ = {
	'A',
	'B',
	'BEAUTIFY',
	'BODY',
	'BR',
	'BUTTON',
	'CENTER',
	'CAT',
	'CODE',
	'COL',
	'COLGROUP',
	'DIV',
	'EM',
	'EMBED',
	'FIELDSET',
	'FORM',
	'H1',
	'H2',
	'H3',
	'H4',
	'H5',
	'H6',
	'HEAD',
	'HR',
	'HTML',
	'I',
	'IFRAME',
	'IMG',
	'INPUT',
	'LABEL',
	'LEGEND',
	'LI',
	'LINK',
	'OL',
	'UL',
	'MARKMIN',
	'MENU',
	'META',
	'OBJECT',
	'ON',
	'OPTION',
	'P',
	'PRE',
	'SCRIPT',
	'OPTGROUP',
	'SELECT',
	'SPAN',
	'STRONG',
	'STYLE',
	'TABLE',
	'TAG',
	'TD',
	'TEXTAREA',
	'TH',
	'THEAD',
	'TBODY',
	'TFOOT',
	'TITLE',
	'TR',
	'TT',
	'URL',
	'XHTML',
	'XML',
	'xmlescape',
	'embed64',
}

local helpers = {
	BR = function() return '<br />' end,
	HR = function() return '<hr />' end,
	URL = function(...)
		print('URL', ...)
		local url = table.concat({...}, '/')
		--[[
		print('URL', urlcode.escape(url))
		return urlcode.escape(url)
		]]--
		return url
	end,
}

local function normalTag(name, text, args) 
	local vals = {}
	table.insert(vals, '<')
	table.insert(vals, name:lower())
	if type(args) == 'table' then
		for k, v in pairs(args) do
			table.insert(vals, ' ')
			table.insert(vals, k)
			table.insert(vals, '=')
			table.insert(vals, v)
		end
	end
	if text and string.len(text) ~= 0 then
		table.insert(vals, '>')
		table.insert(vals, text)
		table.insert(vals, '</')
		table.insert(vals, name:lower())
		table.insert(vals, '>')
	else
		table.insert(vals, ' />')
	end
	return table.concat(vals)
end

local h_env = {}
for k, v in pairs(__all__) do
	h_env[v] = function (...)
		local vals = {}
		if helpers[v] then
			return helpers[v](...)
		else
			return normalTag(v, ...)
		end
	end
end


_M.initHelper = function(env)
	for k, v in pairs(h_env) do
		env[k] = v
	end
end

return _M
