local wezterm = require("wezterm")

local config = {
  font = wezterm.font('JetBrains Mono', { weight = "Regular", stretch = "Normal", style = "Normal" }),
  font_size = 16.0,
  -- harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  audible_bell = "Disabled",
  check_for_updates = true,
  launch_menu = {},

  leader = { key = "m", mods = "CTRL", timeout_milliseconds = 2000 },
  disable_default_key_bindings = true,

  -- cursor_blink_rate = 360,
  -- default_cursor_style = 'BlinkingBlock',
  -- Add this if your laptop/pc doesn't have gpu
  -- animation_fps = 1,
  cursor_blink_ease_in = 'Constant',
  cursor_blink_ease_out = 'Constant',

  color_scheme = "catppuccin",
  -- front_end = "WebGpu",

  -- This is a fix for using with hyprland
  enable_wayland = false,

  colors = {
    cursor_bg = "#eb6f92",
  },

  -- max_fps = 120,

  inactive_pane_hsb = {
    hue = 1.0,
    saturation = 1.0,
    brightness = 1.0,
  },

  enable_tab_bar = false,

  window_decorations = "TITLE|RESIZE",
  background = {
    {
      source = {
        Color = '#181825'
      },
      width = "100%",
      height = "100%",
    },
  },
  -- window_background_opacity = 0.7,
  -- text_background_opacity = 1.0,
  -- macos_window_background_blur = 25,

  keys = {
    -- Send "CTRL-ALT" to the terminal when pressing CTRL-ALT, CTRL-ALT
    { key = "a", mods = "LEADER|CTRL",  action = wezterm.action { SendString = "\x01" } },
    { key = "v", mods = "LEADER",       action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } } },
    { key = "|", mods = "LEADER",       action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
    { key = "z", mods = "LEADER",       action = "TogglePaneZoomState" },
    { key = "c", mods = "LEADER",       action = wezterm.action { SpawnTab = "CurrentPaneDomain" } },
    { key = "h", mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Left" } },
    { key = "j", mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Down" } },
    { key = "k", mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Up" } },
    { key = "l", mods = "LEADER",       action = wezterm.action { ActivatePaneDirection = "Right" } },
    { key = "H", mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Left", 5 } } },
    { key = "J", mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Down", 5 } } },
    { key = "K", mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Up", 5 } } },
    { key = "L", mods = "LEADER|SHIFT", action = wezterm.action { AdjustPaneSize = { "Right", 5 } } },
    { key = "1", mods = "LEADER",       action = wezterm.action { ActivateTab = 0 } },
    { key = "2", mods = "LEADER",       action = wezterm.action { ActivateTab = 1 } },
    { key = "3", mods = "LEADER",       action = wezterm.action { ActivateTab = 2 } },
    { key = "4", mods = "LEADER",       action = wezterm.action { ActivateTab = 3 } },
    { key = "5", mods = "LEADER",       action = wezterm.action { ActivateTab = 4 } },
    { key = "6", mods = "LEADER",       action = wezterm.action { ActivateTab = 5 } },
    { key = "7", mods = "LEADER",       action = wezterm.action { ActivateTab = 6 } },
    { key = "8", mods = "LEADER",       action = wezterm.action { ActivateTab = 7 } },
    { key = "9", mods = "LEADER",       action = wezterm.action { ActivateTab = 8 } },
    { key = "&", mods = "LEADER|SHIFT", action = wezterm.action { CloseCurrentTab = { confirm = true } } },
    { key = "x", mods = "LEADER",       action = wezterm.action { CloseCurrentPane = { confirm = true } } },

    { key = "n", mods = "LEADER",       action = "ToggleFullScreen" },
    { key = "v", mods = "SHIFT|CTRL",   action = wezterm.action.PasteFrom 'Clipboard' },
    { key = "c", mods = "SHIFT|CTRL",   action = wezterm.action.CopyTo 'Clipboard' },
    { key = "+", mods = "LEADER",       action = "IncreaseFontSize" },
    { key = "-", mods = "LEADER",       action = "DecreaseFontSize" },
    { key = "0", mods = "LEADER",       action = "ResetFontSize" },
  },
  set_environment_variables = {},
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  -- config.front_end = "Software" -- OpenGL doesn't work quite well with RDP.
  -- config.term = "" -- Set to empty so FZF works on windows
  table.insert(config.launch_menu, { label = "PowerShell", args = { "powershell.exe", "-NoLogo" } })
else
  config.default_prog = { '/bin/zsh', '-l' }
  -- config.default_cwd = "~/Documents"
end

return config
