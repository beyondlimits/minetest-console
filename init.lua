if minetest.is_singleplayer() then
	minetest.register_on_chat_message(function (name, s)
		local code, result = loadstring('return ' .. s)
		if code == nil then
			code, result = loadstring(s)
		end
		if code then
			code, result = pcall(code)
		end
		if code then
			minetest.chat_send_player(name, dump(result))
		else
			minetest.chat_send_player(name, "ERROR: " .. result)
		end
	end)
end
