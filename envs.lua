local common = ...

local global   = _G
local io       = io
local math     = math
local minetest = minetest
local string   = string
local table    = table

local chat_send_player   = minetest.chat_send_player
local get_player_by_name = minetest.get_player_by_name
local error              = error
local find               = string.find
local format             = string.format
local ipairs             = ipairs
local loadfile           = loadfile
local log                = minetest.log
local pairs              = pairs
local setfenv            = setfenv -- TODO: polyfill for Lua >= 5.1
local setmetatable       = setmetatable
local insert             = table.insert
local sort               = table.sort
local type               = type

local path = minetest.get_modpath(minetest.get_current_modname())

-- for clearing chat window
local bunch_of_lfs = string.rep('\n', 500)

return setmetatable({}, {
	__index = function(envs, name)
	
		local player = get_player_by_name(name)
	
		if player == nil then
			-- no idea how we could get there, but whatever
			log('warning', format('Console attempted to access environment of %s, but there is no such player.', name))
			return {}
		end

		-- variables available for player which cannot be erased
		local own = {
			me = player,
			name = name,
		}

--[[
		-- disabled because it conflicts with at least one method (get_meta)
		local methods = setmetatable({}, {
			__index = function(t, k)
				if player[k] then
					local f = function(...)
						return player[k](player, ...)
					end
					t[k] = f
					return f
				end					
			end
		})
--]]

		-- imports to allow using set_node, sin, write etc.
		-- without the need to reference table directly.
		-- TODO: optimize access?
		local imports = {
			own,       -- me, name
--			methods,   -- getpos(, get_wielded_item(...
			common,    -- extend(, count(, filter(...
			global,    -- standard global stuff
			string,    -- find(, rep(, gmatch(, lower(...
			table,     -- insert(, remove(, sort(, concat(...
			io,        -- open(, input(...
			math,      -- sin(, max(, pi...
			minetest,  -- set_node(, registered_items, CONTENT_AIR...
		}

		-- player environment
		local env = setmetatable({}, {
			-- function for import resolution
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

		-- Those functions are defined here because more or less
		-- they depend on variables in current scope.

		-- Returns a table with all keys of given table
		-- matching the given pattern. If no table provided,
		-- it searches for keys in all imports.
		function own.hint(table, pattern)
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
		function own.clear()
			chat_send_player(name, bunch_of_lfs)
		end

		-- Sends message to player who called it.
		function own.echo(s)
			chat_send_player(name, s)
		end

		-- Loads a script into the function with env being the player env
		local function load(name)
			local result, err = loadfile(path .. '/scripts/' .. name .. '.lua')

			if err then
				error(err)
			end

			return setfenv(result, env)
		end

		own.load = load

		-- Runs a script from scripts directory, using load function above
		function own.run(name, ...)
			return load(name)(...)
		end
		
		return env
	end,
})
