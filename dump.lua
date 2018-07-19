local color    = minetest.get_color_escape_sequence
local concat   = table.concat
local dump     = dump
local insert   = table.insert
local pairs    = pairs
local rep      = string.rep
local sort     = table.sort
local tonumber = tonumber
local type     = type

local indent_size
local max_depth

local handlers = {}
local bucket_order = {'boolean', 'number', 'string'}

local color_unknown   = color('#C99')
local color_nil       = color('#CCC')
local color_boolean   = color('#9CF')
local color_number    = color('#FF9')
local color_string    = color('#9FF')
local color_function  = color('#9F9')
local color_thread    = color('#9FC')
local color_table     = color('#99F')
local color_metatable = color('#FC9')
local color_muted     = color('#999')
local color_userdata  = color('#F99')

local function dump_value(sb, depth, value, full)
	local t = type(value)
	if handlers[t] == nil then
		insert(sb, color_unknown)
		insert(sb, t)
	else
		return handlers[t](sb, depth, value, full)
	end
end

local function dump_nil(sb, depth, value)
	insert(sb, color_nil)
	insert(sb, 'nil')
end;

local function dump_boolean(sb, depth, value)
	insert(sb, color_boolean)
	insert(sb, dump(value))
end

local function dump_number(sb, depth, value)
	insert(sb, color_number)
	insert(sb, dump(value))
end

local function dump_string(sb, depth, value)
	insert(sb, color_string)
	insert(sb, dump(value))
end

local function dump_function(sb, depth, value)
	insert(sb, color_function)
	insert(sb, 'function')
end

local function dump_thread(sb, depth, value)
	insert(sb, color_thread)
	insert(sb, 'thread')
end

local function dump_table_elements(sb, depth, indent, value, keys)
	for k, v in pairs(keys) do
		insert(sb, indent)
		dump_value(sb, depth, v, false)
		insert(sb, color_muted)
		insert(sb, ' = ')
		dump_value(sb, depth, value[v], true)
		insert(sb, '\n')
	end
end

local function dump_table_expanded(sb, depth, value)
	local indent = rep(' ', depth * indent_size)
	local buckets = {}
	local keys = {}

	for k, v in pairs(bucket_order) do
		buckets[v] = {}
	end

	for k, v in pairs(value) do
		insert(buckets[type(k)] or keys, k)
	end

	for k, v in pairs(buckets) do
		sort(v)
	end

	insert(sb, color_table)
	insert(sb, '{')

	if getmetatable(value) ~= nil then
		insert(sb, color_metatable)
		insert(sb, ' contains metatable')
	end

	insert(sb, '\n')

	for k, v in pairs(bucket_order) do
		dump_table_elements(sb, depth, indent, value, buckets[v])
	end

	dump_table_elements(sb, depth, indent, value, keys)

	insert(sb, rep(' ', (depth - 1) * indent_size))
	insert(sb, color_table)
	insert(sb, '}')
end

local function dump_table(sb, depth, value, full)
	if full and depth < max_depth then
		dump_table_expanded(sb, depth + 1, value)
	else
		insert(sb, color_table)
		insert(sb, 'table')

		if getmetatable(value) ~= nil then
			insert(sb, color_metatable)
			insert(sb, ' contains metatable')
		end
	end
end

local function dump_userdata(sb, depth, value, full)
	insert(sb, color_userdata)
	insert(sb, 'userdata ')

	if full and depth < max_depth then
		dump_table_expanded(sb, depth + 1, getmetatable(value))
	end
end

handlers['nil']      = dump_nil
handlers.boolean     = dump_boolean
handlers.number      = dump_number
handlers.string      = dump_string
handlers.userdata    = dump_userdata
handlers['function'] = dump_function
handlers.thread      = dump_thread
handlers.table       = dump_table

return function(value, options)
	indent_size = tonumber(options.indent_size) or 4
	max_depth = tonumber(options.max_depth) or 1

	local sb = {}
	dump_value(sb, 0, value, true)
	return concat(sb)
end
