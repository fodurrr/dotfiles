-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- config.default_domain = 'WSL:Ubuntu-24.04'

-- For example, changing the color scheme:
config.color_scheme = 'Catppuccin Mocha (Gogh)'

-- and finally, return the configuration to wezterm
return config
