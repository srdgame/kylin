
local _M = {}

_M.redirect = function (location, how, client_side)
	how = how or 303
	client_side = client_side or false
	return function(req, res)
		if location then
			if client_side and request.ajax then
				res(200, {}, {'kylin-redirect-location:', location})
			else
				res(how, {Location=location}, {'You are being redirected to <a href="'..location..'">here</a>'})
			end
		else
			res(200, {}, {'kylin-component-command:', 'window.location.reload(true)'})
		end
	end
end


_M.error = function (...)
	local msg = table.concat({...}, '\n')
	return function(req, res)
		res (500, {}, {string.format([[
		<html><head><title>Xavante Error!</title></head>
		<body>
		<h1>Xavante Error!</h1>
		<p>%s</p>
		</body></html>
		]], string.gsub (msg, "\n", "<br/>\n"))})
	end
end

return _M
