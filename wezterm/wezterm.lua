-- https://wezterm.org/config/files.html

local wezterm = require("wezterm")

local config = wezterm.config_builder()
-- config.color_scheme = 'One Half Black (Gogh)'
config.color_scheme = 'Vibrant Ink (Gogh)'
-- config.color_scheme = 'Violet Dark'
-- config.color_scheme = 'VisiBone (terminal.sexy)'
-- config.color_scheme = 'Warm Neon (Gogh)'
config.font = wezterm.font("0xProto Nerd Font Mono", { weight = "Bold" })
config.font_size = 17
config.keys = {
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  -- Make Option-Right equivalent to Alt-f; forward-word
  -- https://github.com/wezterm/wezterm/issues/253#issuecomment-672007120
  {key="LeftArrow", mods="OPT", action=wezterm.action{SendString="\x1bb"}},
  {key="RightArrow", mods="OPT", action=wezterm.action{SendString="\x1bf"}},
}

return config
