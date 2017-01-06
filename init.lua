-- this mod is not intended for multiplayer
if not minetest.is_singleplayer() then
	return
end

local default_color_result = '#00CCFF'
local default_color_error  = '#FFCC00'
local path = minetest.get_modpath(minetest.get_current_modname())

console = {}

dofile(path .. '/config.lua')
dofile(path .. '/console.lua')

if console.enable_helpers then
	dofile(path .. '/helpers.lua')
end

if console.imports then
	dofile(path .. '/imports.lua')
end
