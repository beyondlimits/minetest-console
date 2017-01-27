-- this mod is not intended for multiplayer
if not minetest.is_singleplayer() then
	return
end

local path = minetest.get_modpath(minetest.get_current_modname())

console = {}

dofile(path .. '/config.lua')
dofile(path .. '/console.lua')

if console.enable_helpers then
	dofile(path .. '/helpers.lua')
end
