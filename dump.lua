local color  = minetest.get_color_escape_sequence
local concat = table.concat
local dump   = dump
local insert = table.insert
local pairs  = pairs
local rep    = string.rep
local sort   = table.sort
local type   = type

local indent_size
local max_depth

local handlers = {}

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

local function dump_value(table, depth, value, full)
	local t = type(value)
	if handlers[t] == nil then
		insert(table, color_unknown)
		insert(t)
		return table
	else
		return handlers[t](table, depth, value, full)
	end
end

local function dump_nil(table, depth, value)
	insert(table, color_nil)
	insert(table, 'nil')
end;

local function dump_boolean(table, depth, value)
	insert(table, color_boolean)
	insert(table, dump(value))
end

local function dump_number(table, depth, value)
	insert(table, color_number)
	insert(table, dump(value))
end

local function dump_string(table, depth, value)
	insert(table, color_string)
	insert(table, dump(value))
end

local function dump_function(table, depth, value)
	insert(table, color_function)
	insert(table, 'function')
end

local function dump_thread(table, depth, value)
	insert(table, color_thread)
	insert(table, 'thread')
end

local function dump_table_expanded(table, depth, value)
	local indent = rep(' ', depth * indent_size)

	insert(table, color_table)
	insert(table, '{')

	if getmetatable(value) ~= nil then
		insert(table, color_metatable)
		insert(table, ' contains metatable')
	end

	insert(table, '\n')

	local keys = {}

	for key, value in pairs(value) do
		insert(keys, key)
	end

	pcall(sort, keys)

	for index, key in pairs(keys) do
		insert(table, indent)
		dump_value(table, depth, key, false)
		insert(table, color_muted)
		insert(table, ' = ')
		dump_value(table, depth, value[key], true)
		insert(table, '\n')
	end

	insert(table, rep(' ', (depth - 1) * indent_size))
	insert(table, color_table)
	insert(table, '}')
end

local function dump_table(table, depth, value, full)
	if full and depth < max_depth then
		dump_table_expanded(table, depth + 1, value)
	else
		insert(table, color_table)
		insert(table, 'table')

		if getmetatable(value) ~= nil then
			insert(table, color_metatable)
			insert(table, ' contains metatable')
		end
	end
end

local function dump_userdata(table, depth, value, full)
	insert(table, color_userdata)
	insert(table, 'userdata ')

	if full and depth < max_depth then
		dump_table_expanded(table, depth + 1, getmetatable(value))
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
	indent_size = options.indent_size or 4
	max_depth = options.max_depth or 1

	local table = {}
	dump_value(table, 0, value, true)
	return concat(table, '')
end
