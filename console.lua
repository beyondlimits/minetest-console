local default_color_result      = '#00CCFF'
local default_color_error       = '#FFCC00'
local minetest_colorize         = minetest.colorize
local minetest_chat_send_player = minetest.chat_send_player

local function colorize(s)
	return minetest_colorize(console.color_result or default_color_result, s)
end

minetest.register_on_chat_message(function (name, s)
	local code, result = loadstring('return ' .. s) -- setfenv
	if code == nil then
		code, result = loadstring(s)
	end
	if code then
		code, result = pcall(code, name, s) -- xpcall
	end
	if code then
		_ = result
		minetest_chat_send_player(name, dump(result):gsub('[^\n]*', colorize):gsub('\t', '    '))
	else
		minetest_chat_send_player(name, minetest_colorize(console.color_error or default_color_error, result))
	end
end)
