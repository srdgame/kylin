local urlcode = require('kylin.urlcode')
local logc = require('logging.console')()

return function(app)
	return function (req, res)
		if req.method == 'GET' then
			local querys = {}
			urlcode.parsequery(req.url.query, querys)
			req.query = querys
		end

		app(req, function(code, headers, body)
			res(code, headers, body)
		end)
	end
end
