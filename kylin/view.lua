
local wait = require('fiber').wait
local await = require('fiber').await
local fs = require('uv').fs
local logc = require('logging.console')()

local function out (s, i, f)
	s = string.sub(s, i, f or -1)
	if s == "" then return s end
	-- we could use `%q' here, but this way we have better control
	s = string.gsub(s, "([\\\n\'])", "\\%1")
	-- substitute '\r' by '\'+'r' and let `loadstring' reconstruct it
	s = string.gsub(s, "\r", "\\r")
	return string.format(" %s('%s'); ", "out", s)
end

local function translate(s)
	s = string.gsub(s, "^#![^\n]+\n", "")
	s = string.gsub(s, "<%%(.-)%%>", "<?lua %1 ?>")
	--s = string.gsub(s, "<%?([^l][^u][^a].-)%?>", "<?lua %1 ?>")
	local res = {}
	local start = 1   -- start of untranslated part in `s'
	while true do
		local ip, fp, target, exp, code = string.find(s, "<%?(%w*)[ \t]*(=?)(.-)%?>", start)
		if not ip then break end
		table.insert(res, out(s, start, ip-1))
		if target ~= "" and target ~= "lua" then
			-- not for Lua; pass whole instruction to the output
			table.insert(res, out(s, ip, fp))
		else
			code = string.gsub(code, "(%-%-%[%[.-%]%]%-%-)", "")
			code = string.gsub(code, "(%-%-.+)", "")
			if exp == "=" then   -- expression?
				table.insert(res, string.format(" %s(%s);", 'out', code))
			else  -- command
				table.insert(res, string.format(" %s ", code))
			end
		end
		start = fp + 1
	end
	table.insert(res, out(s, start))
	return table.concat(res)
end

local function layout(path, env)
	--print(path)
	local err, fd = wait(fs.open(path, "r"))
	if not fd then
		return false, 'no layout file'
	end

	local topass = {}
	-- Stream the file to the browser
	repeat
		local chunk = await(fs.read(fd, 1024))
		if #chunk == 0 then
			chunk = nil
		end
		await(function(callback) 
			table.insert(topass, chunk)
			callback()
		end)
	until not chunk

	wait(fs.close(fd))

	wait(function(callback)
		--
		local s = table.concat(topass)
		s = translate(s)
		local f, err = load(s, nil, nil, env)
		if f then
			f()
		else
			logc:error(err)
		end
		callback()
	end)
	return true
end

return {
	layout = layout
}

