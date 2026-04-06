# WezTerm Unicode Input

A WezTerm plugin that intercepts unicode escape sequences and translates them to their respective characters, bypassing the character selection menu.

## Use Case

This plugin was created to enable seamless use of non-standard character sets on keyboards that lack them natively.

**Example:** Writing Romanian on a Brazilian ABNT2 keyboard.

On the ABNT2 layout, many characters specific to Romanian (like ă, â, ș, ț) don't have dedicated keys. While WezTerm provides a built-in character selection menu (`Ctrl+/`), triggering it for every special character disrupts workflow.

### The Solution

1. **Kanata** (keyboard layout remapper) is configured to send unicode escape sequences when the user types specific key combinations:

   ```
   ç + a → sends unicode sequence 103
   ç + f → sends unicode sequence e2 (â)
   ```

2. **WezTerm Unicode Input** captures these sequences and translates them directly to the corresponding characters.

This allows typing Romanian characters as naturally as standard characters—no menus, no interruptions.

## Installation

1. Clone this repository to your WezTerm config directory:

   ```bash
   git clone https://github.com/de-abreu/wezterm-unicode-input.git ~/.config/wezterm/plugins/wezterm-unicode-input
   ```

2. Add the following to your `wezterm.lua`:

   ```lua
   local unicode_input = dofile(os.getenv("HOME") .. "/.config/wezterm/plugins/wezterm-unicode-input/init.lua")

   local config = wezterm.config_builder()

   unicode_input.apply_to_config(config, {
     sequences = {
       ["103"] = "ă",
       ["102"] = "Ă",
       ["e2"] = "â",
       ["c2"] = "Â",
       ["ea"] = "ê",
       ["ca"] = "Ê",
       ["ee"] = "î",
       ["ce"] = "Î",
       ["f4"] = "ô",
       ["d4"] = "Ô",
       ["fb"] = "û",
       ["db"] = "Û",
       ["219"] = "ș",
       ["218"] = "Ș",
       ["21b"] = "ț",
       ["21a"] = "Ț",
     },
   })
   ```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `sequences` | table | `{}` | A mapping of hex key sequences to characters |
| `trigger_key` | string | `"u"` | The key that activates the input sequence |
| `trigger_mods` | string | `"CTRL\|SHIFT"` | Modifier keys for the trigger |
| `timeout_milliseconds` | number | `1000` | Time allowed to complete a sequence |

### Sequence Mapping Format

The keys in `sequences` are the hex codes sent by your keyboard remapper. For example, if kanata sends `"103"` when you type `ç + a`, map it to `"ă"`.

## Example Configuration

### WezTerm (`wezterm.lua`)

```lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

require("modules.unicode-input").apply_to_config(config)

return config
```

### Module (`modules/unicode-input.lua`)

```lua
local wezterm = require "wezterm"
local unicode_input = dofile "/path/to/wezterm-unicode-input/init.lua"
local module = {}

function module.apply_to_config(config)
  if not config.keys then
    config.keys = {}
  end

  table.insert(config.keys, {
    key = "/",
    mods = "CTRL",
    action = wezterm.action.CharSelect,
  })

  unicode_input.apply_to_config(config, {
    sequences = {
      ["103"] = "ă",
      ["102"] = "Ă",
      ["e2"] = "â",
      ["c2"] = "Â",
      ["ea"] = "ê",
      ["ca"] = "Ê",
      ["ee"] = "î",
      ["ce"] = "Î",
      ["f4"] = "ô",
      ["d4"] = "Ô",
      ["fb"] = "û",
      ["db"] = "Û",
      ["219"] = "ș",
      ["218"] = "Ș",
      ["21b"] = "ț",
      ["21a"] = "Ț",
    },
  })
end

return module
```

### Kanata (`special-accents-layer.nix`)

```nix
{
  programs.kanata = {
    sourceKeys = ["ç" "a" "s" "t" "i" "e" "o" "u" "f"];

    aliases = {
      acc_mod = "(tap-hold $tt $ht ç (layer-toggle acc))";

      rom_a = "(fork (unicode ă) (unicode Ă) (lsft rsft))";
      rom_s = "(fork (unicode ș) (unicode Ș) (lsft rsft))";
      rom_t = "(fork (unicode ț) (unicode Ț) (lsft rsft))";
      circ_a = "(fork (unicode â) (unicode Â) (lsft rsft))";
      circ_e = "(fork (unicode ê) (unicode Ê) (lsft rsft))";
      circ_i = "(fork (unicode î) (unicode Î) (lsft rsft))";
      circ_o = "(fork (unicode ô) (unicode Ô) (lsft rsft))";
      circ_u = "(fork (unicode û) (unicode Û) (lsft rsft))";
    };

    layers.base."ç" = "@acc_mod";

    layers.acc = {
      a = "@rom_a";
      s = "@rom_s";
      t = "@rom_t";
      i = "@circ_i";
      f = "@circ_a";
      e = "@circ_e";
      o = "@circ_o";
      u = "@circ_u";
    };
  };
}
```

## WezTerm Config Structure

```
~/.config/wezterm/
├── wezterm.lua
└── modules/
    ├── appearance.lua
    ├── keybinds/
    │   ├── overrides.lua
    │   ├── panes-and-tabs.lua
    │   └── smart-splits.lua
    ├── multiplexing.lua
    ├── rendering.lua
    ├── scrollback-nvim.lua
    ├── tab-bar.lua
    └── unicode-input.lua
```

## License

MIT