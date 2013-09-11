local urlcode = require('kylin.urlcode')
local view = require('kylin.view')
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
	URL = function(path, vars)
		local t = {}
		table.insert(t, path)
		if type(vars) == 'table' then
			table.insert(t, '?')
			local first = true
			for k, v in pairs(vars) do
				if not first then
					table.insert('&')
				else
					first = false
				end
				table.insert(t, urlcode.escape(k))
				table.insert(t, '=')
				table.insert(t, urlcode.escape(v))
			end
		end
		return table.concat(t)
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
			table.insert(vals, '="')
			table.insert(vals, v)
			table.insert(vals, '"')
		end
	end
	if text then
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

_M.initHelper = function(env, app, root)
	for k, v in pairs(h_env) do
		env[k] = function (...) env.out(v(...)) end
		--env[k] = v
	end

	env.include = function(file)
		local f = file:lower()
		if f:match('%.html$') or f:match('%.htm$') then
			env.include_html(file)
		end
		if f:match('%.js$') then
			env.include_js(file)
		end
		if f:match('%.css$') then
			env.include_css(file)
		end
	end
	env.include_css = function(file)
		if not (file:match('://') or file:match('^/')) then
			file = '/'..app..'/static/'..file
		end
		env.out(env.LINK(nil, {href=file, rel='stylesheet'}))
	end
	env.include_js = function(file)
		if not (file:match('://') or file:match('^/')) then
			file = '/'..app..'/static/'..file
		end
		env.out(env.SCRIPT("", {src=file, type='text/javascript', charset='utf-8'}))
	end
	env.include_html = function(file)
		file = root..'/view/'..file
		view.layout(file, env)
	end
	env.URL = function(...)
		local url = h_env.URL(...)
		print(url)
		if not (url:match('://') or url:match('^/')) then
			url = '/'..app..'/'..url
		end
		return url
	end
end

return _M
