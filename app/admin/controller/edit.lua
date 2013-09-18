
return {
	index = function() 
		if req.url.query.app then
			return {}
		else
			return redirect('/')
		end
	end,
}
