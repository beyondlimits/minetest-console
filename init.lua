console = {}

local path = minetest.get_modpath(minetest.get_current_modname())

dofile(path .. '/config.lua')

if not minetest.is_singleplayer() then
	if minetest.settings:get_bool('console_multiplayer') then
		minetest.log('warning', '[console] Console mod has been loaded on multiplayer.')
	else
		return
	end
end

dofile(path .. '/console.lua')
