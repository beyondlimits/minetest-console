local path = minetest.get_modpath(minetest.get_current_modname())

local chat_send_player   = minetest.chat_send_player
local check_player_privs = minetest.check_player_privs
local colorize           = minetest.colorize
local concat             = table.concat
local dump               = dofile(path .. '/dump.lua')
local format             = string.format
local loadstring         = loadstring
local pcall              = pcall
local setfenv            = setfenv -- TODO: polyfill for Lua >= 5.1

-- stuff available for all players
local common = dofile(path .. '/common.lua')

-- players' individual environments
-- the table will be populated for player when needed
local envs = loadfile(path .. '/envs.lua')(common)

-- players' console modes
local mode = {}
local is_singleplayer = minetest.is_singleplayer()

minetest.register_on_joinplayer(function(player)
	mode[player:get_player_name()] = is_singleplayer
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	mode[name] = nil
	envs[name] = nil
end)

if not is_singleplayer then
	minetest.register_chatcommand('console', {
		params = "",
		description = "Toggle console mode",
		privs = {debug = true},
		func = function(name)
			local old = mode[name]
			if old == nil then
				return false, 'Player not found'
			else
				mode[name] = not old
				return true, format('Console mode is now %s.', old and 'disabled' or 'enabled')
			end
		end
	})
end

local pack = common.pack

minetest.register_on_chat_message(function(name, message)
	if not (is_singleplayer or (mode[name] and check_player_privs(name, {debug = true}))) then
		return
	end

	chat_send_player(name, "]" .. message)

	-- try with "return" first to obtain value returned
	-- (e.g. player enters "me:getpos()")
	local f, err = loadstring('return ' .. message)

	if f == nil then
		-- likely a syntax error - try again without "return" keyword
		-- (e.g. player enters "for k, v in ...")
		f, err = loadstring(message)
	end

	if f == nil then
		-- it was real error then
		chat_send_player(name, colorize('#F93', err))
		return true
	end

	local env = envs[name]

	f = pack(pcall(setfenv(f, env)))

	local result = {}

	for i = 2, f.n do
		result[i - 1] = dump(f[i], env)
	end

	result = concat(result, colorize('#999', ', '));

	if f[1] then
		env._ = f[2] -- last result
		chat_send_player(name, result)
	else
		env._e = f[2] -- last error
		chat_send_player(name, colorize('#F93', 'ERROR: ' .. result))
	end

	return true
end)
