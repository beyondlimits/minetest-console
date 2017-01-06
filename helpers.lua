local table_insert = table.insert

function table.keys(table)
	local result = {}
	for key, value in pairs(table) do
		table_insert(result, key)
	end
	return result
end

function table.values(table)
	local result = {}
	for key, value in pairs(table) do
		table_insert(result, value)
	end
	return result
end

function table.filter(table, callback)
	local result = {}
	for key, value in pairs(table) do
		if callback(value, key) then
			result[key] = value
		end
	end
	return result
end
