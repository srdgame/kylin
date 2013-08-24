
local function encodeCookies(cookies)
	local value = {}
	for k, v in pairs(cookies) do
		if #value ~= 0 then
			value[#value + 1] = ';'
		end
		value[#value + 1] = k..'='..v
	end
	return table.concat(value)
end

local function decodeCookies(value)
	local cookies = {}

	for k, v in string.gmatch(value, "(%w+)=(%w+);?") do
		cookies[k] = v
	end
	return cookies
end

return function(app)
	return function (req, res)
		-- find and load session
		for name, value in pairs(req.headers) do
			if name:lower() == "cookie" then
				req.cookies = decodeCookies(value)
			end
		end
		req.cookies = req.cookies or {}

		app(req, function(code, headers, body)
			headers['Set-Cookie'] = encodeCookies(req.cookies)
			res(code, headers, body)
		end)
	end
end

