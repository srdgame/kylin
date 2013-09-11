
return {
	index = function() return {} end,
	submit = function()
		local query = {}
		urlcode.parsequery(req.url.query, query)
		if query.password then
			print(query.password)
			req.session.data = query.password
			redirect(URL('index'))
		else
			for k, v in pairs(query) do
				print(k, v)
			end
		end
	end,
}
