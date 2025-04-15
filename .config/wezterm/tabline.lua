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

    -- Get all available workspaces
    local all_workspaces = wezterm.mux.get_workspace_names()

    -- Get colors from the current theme
    local bg_color = theme.background
    local accent_color = theme.ansi[3]
    local yellow_color = theme.ansi[5] -- Blue for active workspace
    local grey_color = "Grey"          -- Grey for inactive workspaces

    -- Format the workspace name with theme-based styling for left side
    local workspace_text = wezterm.format({
      { Attribute = { Intensity = "Bold" } },
      { Background = { Color = accent_color } },
      { Foreground = { Color = bg_color } },
      { Text = " " .. workspace .. " " },
      { Background = { Color = bg_color } },
      { Foreground = { Color = "Grey" } },
      { Text = " ┃ " },
    })

    -- Create workspace indicators for right side
    local right_status = {}

    -- Add a spacer at the beginning
    table.insert(right_status, { Background = { Color = bg_color } })
    table.insert(right_status, { Foreground = { Color = "Grey" } })
    table.insert(right_status, { Text = " " })

    -- Add each workspace indicator
    for i, ws_name in ipairs(all_workspaces) do
      -- Get first 3 characters of workspace name
      local short_name = string.sub(ws_name, 1, 6)

      -- Determine if this is the active workspace
      local is_active = (ws_name == workspace)
      local ws_bg_color = is_active and yellow_color or grey_color

      -- Add separator between workspace indicators
      if #right_status > 3 then -- Skip the first time
        table.insert(right_status, { Background = { Color = bg_color } })
        table.insert(right_status, { Foreground = { Color = "Grey" } })
        table.insert(right_status, { Text = " " })
      end

      -- Add the workspace indicator with number
      table.insert(right_status, { Background = { Color = ws_bg_color } })
      table.insert(right_status, { Foreground = { Color = bg_color } })
      table.insert(right_status, { Attribute = { Intensity = "Bold" } })
      table.insert(right_status, { Text = " " .. i .. ":" .. short_name .. " " })
    end

    -- Set the left and right status
    window:set_left_status(workspace_text)
    window:set_right_status(wezterm.format(right_status))
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
