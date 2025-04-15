-----------------------------
--- Tabline
-----------------------------
local wezterm = require("wezterm")

local M = {}

M.apply_to_config = function(config)
  config.tab_bar_at_bottom = true
  config.use_fancy_tab_bar = false
  local theme = wezterm.color.get_builtin_schemes()[config.color_scheme]
  -- Custom tab bar with workspace name on the left side
  wezterm.on("update-status", function(window, pane)
    -- Get the current workspace name
    local workspace = window:active_workspace()

    -- Get colors from the current theme
    local bg_color = theme.background
    local accent_color = theme.ansi[3]

    -- Format the workspace name with theme-based styling
    local workspace_text = wezterm.format({
      { Attribute = { Intensity = "Bold" } },
      { Background = { Color = accent_color } },
      { Foreground = { Color = bg_color } },
      { Text = " " .. workspace .. " " },
      { Background = { Color = bg_color } },
      { Foreground = { Color = "Grey" } },
      { Text = " ┃ " },
    })

    -- Set the left status with the workspace name
    window:set_left_status(workspace_text)
  end)

  config.tab_max_width = 26
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    -- local theme = wezterm.color.get_default_colors()
    local fg_color = theme.foreground
    local bg_color = theme.background
    local accent_color = theme.ansi[4]
    local dim_color = "Grey"

    local title = tab.active_pane.title
    -- Truncate the title if it's too long
    if #title > 15 then
      title = wezterm.truncate_right(title, 15) .. "…"
    end

    -- Format for active vs inactive tabs
    if tab.is_active then
      return wezterm.format({
        { Background = { Color = accent_color } },
        { Foreground = { Color = bg_color } },
        { Text = " " .. tab.tab_index + 1 .. " " },
        { Background = { Color = bg_color } },
        { Foreground = { Color = fg_color } },
        { Text = " " .. title .. " " },
        { Background = { Color = bg_color } },
        { Foreground = { Color = "Grey" } },
        { Text = "┃ " },
      })
    else
      return wezterm.format({
        { Background = { Color = dim_color } },
        { Foreground = { Color = bg_color } },
        { Text = " " .. tab.tab_index + 1 .. " " },
        { Attribute = { Italic = true } },
        { Background = { Color = bg_color } },
        { Foreground = { Color = fg_color } },
        { Text = " " .. title .. " " },
        { Background = { Color = bg_color } },
        { Foreground = { Color = "Grey" } },
        { Text = "┃ " },
      })
    end
  end)
end

return M
