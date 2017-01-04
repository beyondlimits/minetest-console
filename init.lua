if minetest.is_singleplayer() then
	local minetest_colorize = minetest.colorize
	local minetest_chat_send_player = minetest.chat_send_player

	local function colorize(s)
		return minetest_colorize('#00CCFF', s)
	end

	minetest.register_on_chat_message(function (name, s)
		local code, result = loadstring('return ' .. s)
		if code == nil then
			code, result = loadstring(s)
		end
		if code then
			code, result = pcall(code)
		end
		if code then
			minetest_chat_send_player(name, dump(result):gsub('[^\n]*', colorize):gsub('\t', '    '))
		else
			minetest_chat_send_player(name, minetest_colorize('#FFCC00', "ERROR: " .. result))
		end
	end)
end
