local wezterm = require("wezterm")
local act = wezterm.action
local module = {}

local function build_key_tables(sequences, timeout)
	local key_tables = { p0 = {} }

	for hex, char in pairs(sequences) do
		local current_table = "p0"

		for i = 1, #hex do
			local digit = hex:sub(i, i)
			local is_last = (i == #hex)
			local next_table = "p_" .. hex:sub(1, i)

			key_tables[next_table] = key_tables[next_table] or {}

			local found = false
			for _, entry in ipairs(key_tables[current_table]) do
				if entry.key == digit then
					found = true
					break
				end
			end

			if not found then
				table.insert(key_tables[current_table], {
					key = digit,
					action = act.ActivateKeyTable({
						name = next_table,
						timeout_milliseconds = timeout,
						one_shot = true,
					}),
				})
			end

			if is_last then
				table.insert(key_tables[next_table], { key = "Space", action = act.SendString(char) })
				table.insert(key_tables[next_table], { key = "Enter", action = act.SendString(char) })
			end

			current_table = next_table
		end
	end

	return key_tables
end

-- This is the public function the user calls in their config
function module.apply_to_config(config, options)
	-- Set defaults just in case the user forgets to pass them
	options = options or {}
	local sequences = options.sequences or {}
	local trigger_key = options.trigger_key or "u"
	local trigger_mods = options.trigger_mods or "CTRL|SHIFT"
	local timeout = options.timeout_milliseconds or 1000

	-- Build the Trie based on the user's sequences
	local new_tables = build_key_tables(sequences, timeout)

	-- Safely initialize WezTerm config tables if they don't exist
	if not config.keys then
		config.keys = {}
	end
	if not config.key_tables then
		config.key_tables = {}
	end

	-- Inject the starting trigger key
	table.insert(config.keys, {
		key = trigger_key,
		mods = trigger_mods,
		action = act.ActivateKeyTable({
			name = "p0",
			timeout_milliseconds = timeout,
			one_shot = true,
		}),
	})

	-- Safely merge the generated tables into the user's existing key tables
	for table_name, rules in pairs(new_tables) do
		config.key_tables[table_name] = rules
	end
end

return module
