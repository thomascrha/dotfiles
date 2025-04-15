local wezterm = require("wezterm")
local M = {}

function M.setup(modal)
  local act = wezterm.action
  -- Define the resize mode key bindings
  local key_table = {
    { key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 10 }) },
    { key = "LeftArrow", mods = "SHIFT", action = act.AdjustPaneSize({ "Left", 3 }) },

    { key = "RightArrow", action = act.AdjustPaneSize({ "Right", 10 }) },
    { key = "RightArrow", mods = "SHIFT", action = act.AdjustPaneSize({ "Right", 3 }) },

    { key = "UpArrow", action = act.AdjustPaneSize({ "Up", 10 }) },
    { key = "UpArrow", mods = "SHIFT", action = act.AdjustPaneSize({ "Up", 3 }) },

    { key = "DownArrow", action = act.AdjustPaneSize({ "Down", 10 }) },
    { key = "DownArrow", mods = "SHIFT", action = act.AdjustPaneSize({ "Down", 3 }) },

    -- Cancel the mode by pressing escape
    { key = "Escape", action = modal.exit_mode("resize") },
    { key = "c", mods = "CTRL", action = modal.exit_mode("resize") },
  }
  local theme = wezterm.color.get_default_colors()
  local accent_color = theme.ansi[4]
  -- Define the status text for resize mode
  local status_text = wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = accent_color } },
    { Text = wezterm.nerdfonts.ple_left_half_circle_thick },
    { Foreground = { Color = "Black" } },
    { Background = { Color = "Yellow" } },
    { Text = "RESIZEAS  " },
  })

  -- Register the resize mode
  modal.add_mode("resize", key_table, status_text)
  -- modal.add_mode("ui", key_table, status_text)
end

return M
