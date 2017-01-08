local minetest = minetest
local mt = getmetatable(_G)
local __index = mt.__index

function mt.__index(table, index, ...)
	local result

	for k, v in pairs(console.imports) do
		local t = type(v)
		if 'string' == t then
			v = _G[v]
			t = type(v)
		end
		if 'table' == t then
			result = v[index]
		elseif 'function' == t then
			result = v(index)
		end
		if result ~= nil then
			return result
		end
	end

	return __index(table, index, ...)
end
