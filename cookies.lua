local cookie = {}

function cookie:tostring()
	local value = {}
	value[#value + 1] = self.value
	if self.expire then
		value[#value + 1] = 'Expires='..os.date('!%a, %d %b %Y %X GMT', self.expire)
	end
	if self.path then
		value[#value + 1] = 'Path='..self.path
	else
		value[#value + 1] = 'Path=/'
	end
	if self.domain then
		value[#value + 1] = 'Domain='..self.domain
	end
	if self.http_only then
		value[#value + 1] = 'HttpOnly'
	end
	local v = table.concat(value, "; ")
	--print(v)
	return v
end

function cookie:update(time_span)
	self.updated = true
	if not time_span then
		self.expire = nil
	else
		self.expire = os.time() + time_span
	end
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
		updated = true,
	}, {__index = cookie})
end

local function encodeCookies(cookies)
	local value = {}
	for k, v in pairs(cookies) do
		if v.updated  then
			if #value ~= 0 then
				value[#value + 1] = '; '
			end
			if type(v) == 'table' then
				value[#value + 1] = k..'='..v:tostring()
			else
				value[#value + 1] = k..'='..v
			end
		end
	end
	return table.concat(value)
end

local function decodeCookies(value)
	local cookies = {}
	for k, v in string.gmatch(value, "([^=]+)=([^%s]+)[;%s]?") do
		cookies[k] = _M.newCookie(k, v)
		cookies[k].updated = false
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
