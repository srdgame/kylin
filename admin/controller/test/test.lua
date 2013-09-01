return {
	index = function()
		if test_model then
			test_model()
		else
			print('test_model not exist')
		end
		return "test"
	end
}
