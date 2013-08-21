
local _M = {}

_M.redirect = function (location, how, client_side)
	how = how or 303
	client_side = client_side or false
	return function(req, res)
		if location then
			if client_side and request.ajax then
				res(200, {}, {'kylin-redirect-location:', location})
			else
				res(how, {Location=location}, {'You are being redirected to <a href="'..req.url.path..location..'">here</a>'})
			end
		else
			res(200, {}, {'kylin-component-command:', 'window.location.reload(true)'})
		end
	end
end

return _M
