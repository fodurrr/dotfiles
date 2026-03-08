-- =============================================================================
-- WezTerm Configuration
-- =============================================================================
-- Appearance and behavior only. All keybindings are WezTerm defaults.
-- Works standalone (tabs + splits) or as a rendering layer for tmux.
-- =============================================================================

local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- =============================================================================
-- Appearance
-- =============================================================================
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 16.0

-- Padding
config.window_padding = {
  left = 12,
  right = 12,
  top = 10,
  bottom = 10,
}

-- Cursor
config.default_cursor_style = "SteadyBlock"

-- Window
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.max_fps = 165 -- Match your 165Hz monitor

-- =============================================================================
-- Tab bar
-- =============================================================================
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 32

-- =============================================================================
-- Scrollback
-- =============================================================================
config.scrollback_lines = 10000

-- =============================================================================
-- Inactive pane dimming (visual distinction for splits)
-- =============================================================================
config.inactive_pane_hsb = {
  saturation = 0.85,
  brightness = 0.7,
}

-- =============================================================================
-- Custom keybindings (only overrides — everything else is WezTerm default)
-- =============================================================================
config.keys = {
  -- Splits
  { key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Navigate splits
  { key = "LeftArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "CMD|SHIFT", action = act.ActivatePaneDirection("Down") },

  -- Command palette & quick select
  { key = "p", mods = "CMD|SHIFT", action = act.ActivateCommandPalette },
  { key = "u", mods = "CMD|SHIFT", action = act.QuickSelect },
}

-- =============================================================================
-- Input
-- =============================================================================
config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false

-- =============================================================================
-- macOS
-- =============================================================================
config.native_macos_fullscreen_mode = true

-- =============================================================================
-- Performance (WebGPU → Metal on macOS)
-- =============================================================================
config.front_end = "WebGpu"

return config
