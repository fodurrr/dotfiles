-- =============================================================================
-- WezTerm Configuration
-- =============================================================================
-- Appearance and behavior. A few keybindings override WezTerm defaults.
-- Works standalone (tabs + splits) or as a rendering layer for tmux.
-- =============================================================================

local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Modifier keys per platform. macOS uses Cmd. Linux uses Ctrl+Shift, the
-- terminal convention there; the desktop owns Super and Ctrl+Alt+arrows.
local is_macos = wezterm.target_triple:find("darwin") ~= nil
local MOD = is_macos and "CMD" or "CTRL|SHIFT"
local MOD_ALT = is_macos and "CMD|SHIFT" or "ALT|SHIFT"
local LINK_MOD = is_macos and "CMD" or "CTRL"

-- =============================================================================
-- Appearance
-- =============================================================================
-- Explicit Catppuccin Mocha colors (matched to Ghostty's theme file)
config.color_scheme = "Catppuccin Mocha"
config.colors = {
  background = "#1e1e2e",
  foreground = "#cdd6f4",
  cursor_bg = "#f5e0dc",
  cursor_fg = "#1e1e2e",
  selection_bg = "#585b70",
  selection_fg = "#cdd6f4",
  split = "#f9e2af", -- Match Ghostty split-divider-color
  ansi = {
    "#45475a", -- black
    "#f38ba8", -- red
    "#a6e3a1", -- green
    "#f9e2af", -- yellow
    "#89b4fa", -- blue
    "#f5c2e7", -- magenta
    "#94e2d5", -- cyan
    "#a6adc8", -- white
  },
  brights = {
    "#585b70", -- bright black
    "#f37799", -- bright red
    "#89d88b", -- bright green
    "#ebd391", -- bright yellow
    "#74a8fc", -- bright blue
    "#f2aede", -- bright magenta
    "#6bd7ca", -- bright cyan
    "#bac2de", -- bright white
  },
}

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 16.0
config.line_height = 1

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
config.window_background_opacity = 0.88
config.macos_window_background_blur = 20
config.window_decorations = "TITLE|RESIZE"
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
-- Inactive pane dimming (subtle — keep colors close to Ghostty feel)
-- =============================================================================
config.inactive_pane_hsb = {
  saturation = 0.95,
  brightness = 0.9,
}

-- =============================================================================
-- Custom keybindings (only overrides — everything else is WezTerm default)
-- =============================================================================
config.keys = {
  -- Splits
  { key = "d", mods = MOD, action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = MOD_ALT, action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Navigate splits
  { key = "LeftArrow", mods = MOD_ALT, action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = MOD_ALT, action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = MOD_ALT, action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = MOD_ALT, action = act.ActivatePaneDirection("Down") },

  -- Close current pane (not tab) — matches Ghostty Cmd+W behavior
  { key = "w", mods = MOD, action = act.CloseCurrentPane({ confirm = false }) },

  -- Command palette & quick select
  { key = "p", mods = MOD_ALT, action = act.ActivateCommandPalette },
  { key = "u", mods = MOD_ALT, action = act.QuickSelect },

  -- Shift+Enter → newline in Claude Code (CSI u encoding for modified Enter)
  { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b[13;2u") },

}

if is_macos then
  -- Let Pi receive Ctrl+V directly for clipboard image paste.
  -- Cmd+V remains WezTerm/macOS text paste.
  table.insert(config.keys, { key = "V", mods = "CTRL", action = act.DisableDefaultAssignment })
else
  -- Linux: Ctrl+Shift+V pastes and Shift+Insert pastes the clipboard too.
  -- Plain Ctrl+V still goes to the program inside (Pi image paste).
  -- The macOS rule above must not run here: WezTerm reads key "V" + CTRL as
  -- Ctrl+Shift+V, so it would switch the Linux paste shortcut off.
  table.insert(config.keys, { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") })
  table.insert(config.keys, { key = "Insert", mods = "SHIFT", action = act.PasteFrom("Clipboard") })
end

-- =============================================================================
-- Hyperlinks — Cmd+Click to open URLs in browser
-- =============================================================================
config.mouse_bindings = {
  -- Cmd+Click to open links
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = LINK_MOD,
    action = act.OpenLinkAtMouseCursor,
  },
  -- Right-click: copy if text selected, paste if not
  {
    event = { Up = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and sel ~= "" then
        window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
      else
        window:perform_action(act.PasteFrom("Clipboard"), pane)
      end
    end),
  },
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
-- Linux
-- =============================================================================
if not is_macos then
  -- GNOME on Wayland draws no title bar for WezTerm, so the window cannot be
  -- moved, resized or closed with the mouse. Under XWayland the desktop draws
  -- its normal title bar with all window buttons.
  config.enable_wayland = false
  config.default_cursor_style = "BlinkingBlock"
end

-- =============================================================================
-- Performance (WebGPU → Metal on macOS)
-- =============================================================================
config.front_end = "WebGpu"

return config
