local insert   = table.insert
local pairs    = pairs
local rawequal = rawequal
local select   = select

local common = {}

-- table.count
function common.count(table)
	local n = 0
	for key, value in pairs(table) do
		n = n + 1
	end
	return n
end

-- table.keys
function common.keys(table)
	local result = {}
	for key, value in pairs(table) do
		insert(result, key)
	end
	return result
end

-- table.values
function common.values(table)
	local result = {}
	for key, value in pairs(table) do
		insert(result, value)
	end
	return result
end

-- table.extend
local function extend(table, other, ...)
	if other == nil then
		return table
	end
	for key, value in pairs(other) do
		table[key] = value
	end
	return extend(table, ...)
end

common.extend = extend

-- table.filter
function common.filter(table, callback)
	local result = {}
	for key, value in pairs(table) do
		if callback(value, key) then
			result[key] = value
		end
	end
	return result
end

-- table.pack
-- TODO: may conflict with Lua >= 5.1
function common.pack(...)
	return {n = select('#', ...), ...}
end

-- math.isnan
--[[
function common.isnan(x)
	return not rawequal(x, x)
end
--]]

return common
