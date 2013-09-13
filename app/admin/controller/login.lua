
return {
	index = function() return {} end,
	submit = function()
		local password = nil
		if req.method == 'GET' then
			local query = req.url.query
			password = query.password
		else
			password = req.posts.password
		end

		if password and login(password) then
			print('login sucessfully!!!, password:', password)
			req.session.data = password
			print('submit', req.session.data)
			redirect(URL('/'))
		else
			print('login failed!!!')
			redirect(URL('login'))
		end

	end,
}
