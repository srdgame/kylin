
local function encodeCookies(cookies)
	local value = {}
	for k, v in pairs(cookies) do
		if #value ~= 0 then
			value[#value + 1] = '; '
		end
		value[#value + 1] = k..'='..v
	end
	value[#value + 1] = '\r\n'
	return table.concat(value)
end

local function decodeCookies(value)
	local cookies = {}

	for k, v in string.gmatch(value, "([^=]+)=([^%s]+)[;\r%s]?") do
		cookies[k] = v
	end
	return cookies
end


local c = {}
c['kylin_session'] = 'sddaddfadfa'
c['Set-Session'] = 'dfaaf'
c['use'] = 'ture'

local v = encodeCookies(c)
print(v)

local t = decodeCookies(v)
for k, v in pairs(t) do
	print(k, v)
end
