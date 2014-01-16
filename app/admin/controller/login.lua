
return {
	index = function() return {} end,
	submit = function()
		local password = nil
		if req.method == 'GET' then
			local query = req.query
			password = query.password
		else
			password = req.post.password
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
	change = function()
		if req.method ~= 'POST' then
			return redirect(URL('login/modify'))
		end
		print('update password')
		orig_pass = req.post.orig_password
		new_pass = req.post.new_password
		local r, info = auth.updatePass(orig_pass, new_pass)
		log(info)
		return redirect(URL('#', {info=info}))
	end,
	modify = function()
		if req.session.data == nil then
			return redirect(URL('login'))
		end
		return {}
	end,
}
