local cookie = {}

function cookie:tostring()
	local value = {}
	value[#value + 1] = self.key.."="..self.value
	if self.expire then
		value[#value + 1] = 'Expires='..os.date('!%a, %d %b %Y %X CUT', self.expire)
	end
	if self.path then
		value[#value + 1] = 'Path='..self.path
	end
	if self.domain then
		value[#value + 1] = 'Domain='..self.domain
	end
	if self.http_only then
		value[#value + 1] = 'HttpOnly'
	end
	local v = table.concat(value, "; ")
	print(v)
end

local _M = {}

function _M.newCookie(key, value, path, expire, domain, http_only)
	return setmetatable(
	{
		key = key,
		value = value,
		path = path,
		expire = expire,
		domain = domain,
		http_only = http_only,
	}, {__index = cookie})
end

local function encodeCookies(cookies)
	local value = {}
	for k, v in pairs(cookies) do
		if #value ~= 0 then
			value[#value + 1] = '; '
		end
		value[#value + 1] = k..'='..v
	end
	return table.concat(value)
end

local function decodeCookies(value)
	local cookies = {}
	for k, v in string.gmatch(value, "([^=]+)=([^%s]+)[;%s]?") do
		cookies[k] = v
	end
	return cookies
end

function _M.web(app)
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

return _M
