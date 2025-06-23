-- https://wezterm.org/config/files.html

local wezterm = require("wezterm")

local config = wezterm.config_builder()
config.color_scheme = "Aardvark Blue"
config.font = wezterm.font("0xProto Nerd Font Mono", { weight = "Bold" })
config.font_size = 14
return config
