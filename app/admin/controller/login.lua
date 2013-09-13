
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

		if password and auth.login(password) then
			print('login sucessfully!!!, password:', password)
			req.session.data = password
			print('submit', req.session.data)
			return redirect(URL(''))
		else
			print('login failed!!!')
			return redirect(URL('login'))
		end

	end,
	logout = function()
		print('logout user!!!')
		req.session.data = nil
		return redirect(URL(''))
	end,
}
