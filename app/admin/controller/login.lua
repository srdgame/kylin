
return {
	index = function() return {} end,
	submit = function()
		local password = nil
		if req.method == 'GET' then
			--[[
			local query = {}
			urlcode.parsequery(req.url.query, query)
			]]
			local query = req.url.query
			password = query.password
		else
			password = req.posts.password
		end

		if password then
			print('login sucessfully!!!, password:', password)
			req.session.data = password
			redirect(URL('index'))
		else
			for k, v in pairs(query) do
				print(k, v)
			end
			print('login failed!!!')
			redirect(URL('login'))
		end

	end,
}
