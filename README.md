# minetest-console
Minetest mod which transforms chat window into [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop).

For convenience, these variables are available in the scope of the REPL:

- `_` - last result
- `_e` - last error
- `me` - player's object (userdata)
- `name` - player's name

Additionally, these tables are imported:

- `string`
- `table`
- `io`
- `math`
- `minetest`

Thus instead of `string.rep`, `table.insert` or `minetest.set_node`, one can simply type `rep`, `insert` or `set_node`.

There are helper functions available:

- `hint(table, pattern)` - Returns a table with all keys of `table` matching `pattern` (same format as in `string.find`). If `table` is omitted, it searches within all imported tables.
- `clear()` - Clears the chat window (by spamming a lot of empty lines).
- `echo(message)` - Sends message to the player who called it. Useful when called from delayed code (e.g. attached to event or via `minetest.after`).
- `load(name)` - Loads a script from the `scripts` directory into function. Extension `.lua` is added automatically. The arguments passed to the returned function are obtained via `...` (e.g. `local x, y, z = ...`) within a script. Convenience variables and imported tables apply to scripts as well.
- `run(name, arg1, arg2, ...)` - Equivalent to `load(name)(arg1, arg2, ...)`. Arguments are of course optional.
- `count(table)` - Returns the number of elements in `table`. The function was added since neither `#` nor `table.getn` work properly with associative tables.
- `keys(table)` - Returns all keys of `table`. Resulting table is numerically indexed.
- `values(table)` - Returns all values of `table`. Resulting table is numerically indexed.
- `extend(table, other, ...)` - Merges one or more tables into `table` and returns `table`. To return new table instead of modifying, use it like `extend({}, table, other, ...)`.
- `filter(table, callback)` - For every element of `table` calls `callback(value, key)` and returns only elements for which `callback` returns `true` or true-like value.
- `pack(...)` - Packs provided arguments into table. Resulting table contains key `n` which is the number of provided arguments. Supposed to be equivalent of `table.pack` in Lua >= 5.2.

These variables can be set to adjust display of tables:
- `indent_size` - Indent size in spaces. When not set, defaults to `4`.
- `max_depth` - Maximum depth of nested tables. When this limit is hit, REPL displays `table` instead of table contents. When not set, defaults to `1`.

Multiplayer mode is disabled by default. To enable it, `console_multiplayer` setting must be set to `true` and the players that are supposed to use REPL need `debug` privilege. REPL is toggled using `/console` command.

![Screenshot 1](https://user-images.githubusercontent.com/7702857/42846454-4e431ab2-8a19-11e8-86f7-e76b879eb266.png)
![Screenshot 2](https://user-images.githubusercontent.com/7702857/42846455-4e6c8334-8a19-11e8-9504-4b99ee20ff3b.png)
![Screenshot 3](https://user-images.githubusercontent.com/7702857/42846456-4ea1ab04-8a19-11e8-9015-ab49b6f64fa3.png)
![Screenshot 4](https://user-images.githubusercontent.com/7702857/42846457-4ecc8aa4-8a19-11e8-8c72-6e05df11d0b2.png)
![Screenshot 5](https://user-images.githubusercontent.com/7702857/42846458-4f047a72-8a19-11e8-9894-0456ec6ea337.png)
![Screenshot 6](https://user-images.githubusercontent.com/7702857/42846459-4f681d02-8a19-11e8-83bb-174d72439951.png)
![Screenshot 7](https://user-images.githubusercontent.com/7702857/42846460-4ff3ed78-8a19-11e8-862e-595b2027dc06.png)
![Screenshot 8](https://user-images.githubusercontent.com/7702857/42846462-50863b38-8a19-11e8-9257-09d8a695347e.png)
