local path = minetest.get_modpath(minetest.get_current_modname())

local chat_send_player = minetest.chat_send_player
local colorize         = minetest.colorize
local concat           = table.concat
local dump             = dofile(path .. '/dump.lua')
local find             = string.find
local getmetatable     = getmetatable
local insert           = table.insert
local ipairs           = ipairs
local loadstring       = loadstring
local pairs            = pairs
local pcall            = pcall
local rep              = string.rep
local select           = select
local setfenv          = setfenv
local setmetatable     = setmetatable
local sort             = table.sort
local type             = type

-- players' environments
local envs = {}

-- stuff available for all players
local function pack(...)
	local result = {...}
	result.n = select('#', ...)
	return result
end

local g_environ = {
	gmt  = getmetatable, -- shorthand for getmetatable
	smt  = setmetatable, -- shorthand for setmetatable
}

local bunch_of_lfs = rep('\n', 500)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	-- variables available for player which cannot be erased
	local environ = {
		me = player,
		name = name,
	}

	-- imports to allow using set_node, sin, write etc.
	-- without direct reference to player.
	local imports = {environ, g_environ, _G, string, table, io, math, minetest}

	-- player environment
	local env = setmetatable({}, {
		-- function for resolving imports
		__index = function(table, index)
			local result

			for i, import in ipairs(imports) do
				local result = import[index]
				if result ~= nil then
					return result
				end
			end
		end
	})

	envs[name] = env

	-- Returns a table with all keys of given table
	-- matching the given pattern. If no table provided,
	-- it searches for keys in all imports.
	environ.hint = function(table, pattern)
		local result = {}
		if pattern == nil then
			pattern = table
			table = {}
			for i, import in ipairs(imports) do
				for key, value in pairs(import) do
					if find(key, pattern) then
						table[key] = value
					end
				end
			end
			for key, value in pairs(table) do
				insert(result, key)
			end
		else
			if type(table) ~= 'table' then
				error('Table expected')
			end
			for key, value in pairs(table) do
				if find(key, pattern) then
					insert(result, key)
				end
			end
		end
		sort(result)
		return result
	end

	-- Clears the chat window.
	environ.clear = function()
		chat_send_player(name, bunch_of_lfs)
	end

	-- Sends message to player who called it.
	environ.echo = function(s)
		chat_send_player(name, s)
	end

	local function load(name)
		local result, err = loadfile(path .. '/scripts/' .. name)

		if err then
			error(err)
		end

		return setfenv(result, env)
	end

	environ.load = load

	-- Runs a script from scripts directory.
	environ.run = function(name, ...)
		return load(name)(...)
	end
end)

minetest.register_on_leaveplayer(function(player)
	envs[player:get_player_name()] = nil
end)

minetest.register_on_chat_message(function(name, s)
	local f, err = loadstring('return ' .. s)

	if f == nil then
		f, err = loadstring(s)
	end

	if f == nil then
		chat_send_player(name, colorize('#F93', err))
		return
	end

	local env = envs[name]

	f = pack(pcall(setfenv(f, env)))

	local result = {}

	for i = 2, f.n do
		result[i - 1] = dump(f[i], env)
	end

	result = concat(result, '(c@#999), ');

	if f[1] then
		env._ = f[2]
		chat_send_player(name, result)
	else
		env._e = f[2]
		chat_send_player(name, '(c@#F93)ERROR: ' .. result)
	end
end)
