if minetest.is_singleplayer() then
	minetest.register_on_chat_message(function (name, s)
		if string.sub(s, 1, 1) == "=" then
			s = "return " .. string.sub(s, 2)
		end
		local result
		local status, err = pcall(function()
			result = loadstring(s)()
		end)
		if status then
			minetest.chat_send_player(name, dump(result))
		else
			minetest.chat_send_player(name, "ERROR: " .. err)
		end
	end)
end
