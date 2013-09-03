
local urlcode = require('kylin.urlcode')

return function(app)
	return function(req, res)
		--print(req.url.path)
		req.url.path = urlcode.unescape(req.url.path)
		--print(req.url.path)
		app(req, function(code, headers, body)
			res(code, headers, body)
		end)
	end
end
