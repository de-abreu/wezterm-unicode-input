# WezTerm Unicode Input

A WezTerm plugin that intercepts unicode escape sequences and translates them to
their respective characters, bypassing the character selection menu.

## Use Case

This plugin was created to enable seamless use of non-standard character sets on
keyboards that lack them natively. Solves
[wezterm/issues/7063](https://github.com/wezterm/wezterm/issues/7063).

**Example:** Writing Romanian on a Brazilian ABNT2 keyboard.

On the ABNT2 layout, many characters specific to Romanian (like ă, â, ș, ț)
don't have dedicated keys. While WezTerm provides a built-in character selection
menu, but triggering it for every special character disrupts workflow.

### The Solution

1. **Kanata** (keyboard layout remapper) is configured trigger macros of the
   form:

```
(<trigger key combination>) (<unicode hex without leading zeroes>) (Enter)
```

> [!NOTE]
>
> The trigger combo in Kanata is `<C-S-u>`, but for the purposes of this plugin
> could be any other. Also the confirmation key can be either `<Enter>` or
> `<Space>`.

2. **WezTerm Unicode Input** captures these sequences and translates them
   directly to the corresponding characters.

This allows typing Romanian characters as naturally as standard characters — no
menus, no interruptions.

## Installation

Either add the following line to `wezterm.lua`:

```lua
local unicode_input = wezterm.plugin.require "https://github.com/de-abreu/wezterm-unicode-input"
```

Or to a module definition that gets exported to `wezterm.lua`, either way the
plugin will be available.

## Configuration Options

| Option                 | Type   | Default         | Description                                  |
| ---------------------- | ------ | --------------- | -------------------------------------------- |
| `sequences`            | table  | `{}`            | A mapping of hex key sequences to characters |
| `trigger_key`          | string | `"u"`           | The key that activates the input sequence    |
| `trigger_mods`         | string | `"CTRL\|SHIFT"` | Modifier keys for the trigger                |
| `timeout_milliseconds` | number | `1000`          | Time allowed to complete a sequence          |

> [!WARNING]
>
> By default, the trigger key and mods clash with those Wezterm has defined for
> its character selection menu. To retain access to it, its is recommended to
> change its keybind. See the example configuration.

## Example Configuration

Here is my Wezterm + Kanata configuration with Wezterm Unicode Input added as a
module.

### WezTerm (`wezterm.lua`)

```lua
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- other modules...
require("modules.keyvinds.unicode-input").apply_to_config(config)

return config
```

### Module (`modules/unicode-input.lua`)

```lua
local wezterm = require "wezterm"
local unicode_input = wezterm.plugin.require "https://github.com/de-abreu/wezterm-unicode-input"
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
    ├── keybinds/
    │   ├── ...
    │   └── unicode-input.lua
    └── ...
```
