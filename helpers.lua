local insert = table.insert

function table.count(table)
	local n = 0
	for key, value in pairs(table) do
		n = n + 1
	end
	return n
end

function table.keys(table)
	local result = {}
	for key, value in pairs(table) do
		insert(result, key)
	end
	return result
end

function table.values(table)
	local result = {}
	for key, value in pairs(table) do
		insert(result, value)
	end
	return result
end

local function extend(table, other, ...)
	if other == nil then
		return table
	end
	for key, value in pairs(other) do
		table[key] = value
	end
	return extend(table, ...)
end

table.extend = extend

function table.filter(table, callback)
	local result = {}
	for key, value in pairs(table) do
		if callback(value, key) then
			result[key] = value
		end
	end
	return result
end

function math.isnan(x)
	return not rawequal(x, x)
end

function pack(...)
	local result = {...}
	result.n = select('#', ...)
	return result
end
