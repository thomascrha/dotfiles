local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- TODO remove this when the issue is fixed
-- config.enable_wayland = false
--
-----------------------------
--- Guake mode
-----------------------------
-- makes the window transparent when in guake mode is detected
local mode = os.getenv("WEZTERM_GUAKE")
if mode == "on" then
  config.window_background_opacity = 0.7
end

-----------------------------
--- General settings
-----------------------------
config.enable_wayland = true
-- workaround for wayland when trying to create new windows in a scaled display
-- config.default_gui_startup_args = {'start', '--always-new-process'}

config.color_scheme = 'OneHalfDark'
config.font_size = 11
config.hide_tab_bar_if_only_one_tab = false
config.enable_tab_bar = true
config.enable_scroll_bar = false
config.window_close_confirmation = "NeverPrompt"

config.audible_bell = 'Disabled'
config.font = wezterm.font('JetBrains Mono')

config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

-- Make sure word selection stops on most punctuations.
--
-- Note that dot (.) & slash (/) are allowed though for
-- easy selection of (partial) paths.
config.selection_word_boundary = " \t\n{}[]()\"'`,;:@│*"

config.tab_bar_at_bottom = true


-----------------------------
--- Windows
-----------------------------
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'wsl.exe', '-d', 'Ubuntu-22.04'}
end

-----------------------------
--- Plugins
-----------------------------

-- Tabline
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = { theme = 'OneHalfDark' }
})

-- local bar= wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")

local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
-- resuurrect.wezterm
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- loads the state whenever I create a new workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
  local workspace_state = resurrect.workspace_state

  workspace_state.restore_workspace(resurrect.load_state(label, "workspace"), {
    window = window,
    relative = true,
    restore_text = true,
    on_pane_restore = resurrect.tab_state.default_on_pane_restore,
  })
end)

-- Saves the state whenever I select a workspace
wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
  local workspace_state = resurrect.workspace_state
  resurrect.save_state(workspace_state.get_workspace_state())
end)

local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")

local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    sessionizer.config.paths = {
        "/home/tcrha/qbe"
    }
end
sessionizer.config.paths = {
  "/home/tcrha/Projects",
  "/home/tcrha/dotfiles"
}

-----------------------------
--- Keybindings
-----------------------------
---
local act = wezterm.action
config.leader = { key = '`', mods = 'ALT', timeout_milliseconds = 1000 }
config.keys = {
  {
    key = "/",
    mods = "LEADER",
    action = sessionizer.show,
  },
  {
    key = "Tab",
    mods = "LEADER",
    action = sessionizer.switch_to_most_recent,
  },
  {
    key = "s",
    mods = "LEADER",
    action = workspace_switcher.switch_workspace(),
  },
  -- This will create a newconfig.keys = {
  -- This will create a new split and run your default program inside it
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = false }},
  { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollByLine(-1) },
  { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollByLine(1) },
  { key = 'PageUp', action = act.ScrollByPage(-0.8) },
  { key = 'PageDown', action = act.ScrollByPage(0.8) },

  { key = "-", mods = "LEADER", action = act.SplitVertical { domain="CurrentPaneDomain" }},
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal { domain="CurrentPaneDomain" }},
  { key = 'UpArrow', mods = "ALT", action = act.ActivatePaneDirection "Up" },
  { key = 'LeftArrow', mods = "ALT", action = act.ActivatePaneDirection "Left" },
  { key = 'DownArrow', mods = "ALT", action = act.ActivatePaneDirection "Down" },
  { key = 'RightArrow', mods = "ALT", action = act.ActivatePaneDirection "Right" },

  { key = 'c', mods = "LEADER", action = act.SpawnTab "CurrentPaneDomain" },
  { key = 'w', mods = "LEADER", action = act.CloseCurrentTab { confirm = false }},
  -- goto tabs via index
  { key = '1', mods = "LEADER", action = act.ActivateTab(0) },
  { key = '2', mods = "LEADER", action = act.ActivateTab(1) },
  { key = '3', mods = "LEADER", action = act.ActivateTab(2) },
  { key = '4', mods = "LEADER", action = act.ActivateTab(3) },
  { key = '5', mods = "LEADER", action = act.ActivateTab(4) },
  { key = '6', mods = "LEADER", action = act.ActivateTab(5) },
  { key = '7', mods = "LEADER", action = act.ActivateTab(6) },
  { key = '8', mods = "LEADER", action = act.ActivateTab(7) },
  { key = '9', mods = "LEADER", action = act.ActivateTab(8) },
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      -- initial_value = 'My Tab Name',
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  {
    key = ".",
    mods = "LEADER",
    action = wezterm.action.PromptInputLine({
      description = "Enter new name for workspace",
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
        end
      end),
    }),
  },
  {
    key = 'n',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            act.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    },
  },

  -- Resurrect
  {
    key = "d",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_load(win, pane, function(id)
          resurrect.delete_state(id)
        end,
        {
          title = "Delete State",
          description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
          fuzzy_description = "Search State to Delete: ",
          is_fuzzy = true,
        })
    end),
  },
  {
    key = "w",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      resurrect.save_state(resurrect.workspace_state.get_workspace_state())
      win:toast_notification('wezterm', 'configuration saved', nil, 4000)
    end),
  },
  {
    key = "r",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_load(win, pane, function(id, label)
        local type = string.match(id, "^([^/]+)") -- match before '/'
        id = string.match(id, "([^/]+)$") -- match after '/'
        id = string.match(id, "(.+)%..+$") -- remove file extention
        local opts = {
          -- do in the current window
          -- window = win:mux_window(), -- THIS IS THE NEW PART
          relative = true,
          restore_text = true,
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        }
        if type == "workspace" then
          local state = resurrect.load_state(id, "workspace")
          resurrect.workspace_state.restore_workspace(state, opts)
          -- send notification
          -- win:toast_notification("Wezterm - resurrect", "Workspace " .. label .. " restored", nil, 4000)
        elseif type == "window" then
          local state = resurrect.load_state(id, "window")
          resurrect.window_state.restore_window(pane:window(), state, opts)
        elseif type == "tab" then
          local state = resurrect.load_state(id, "tab")
          resurrect.tab_state.restore_tab(pane:tab(), state, opts)
        end
      end)
    end),
  },
}

local resurrect_event_listeners = {
  "resurrect.error",
  "resurrect.save_state.finished",
}
local is_periodic_save = false
wezterm.on("resurrect.periodic_save", function()
  is_periodic_save = true
end)
for _, event in ipairs(resurrect_event_listeners) do
  wezterm.on(event, function(...)
    if event == "resurrect.save_state.finished" and is_periodic_save then
      is_periodic_save = false
      return
    end
    local args = { ... }
    local msg = event
    for _, v in ipairs(args) do
      msg = msg .. " " .. tostring(v)
    end
    wezterm.gui.gui_windows()[1]:toast_notification("Wezterm - resurrect", msg, nil, 4000)
  end)
end



-- Must be the last line
workspace_switcher.apply_to_config(config)
modal.apply_to_config(config)
resurrect.periodic_save()
-- bar.apply_to_config(
--   config,
--   {
--     colors = {
--       tab_bar = {
--         active_tab = {
--           bg_color = "#000000"
--         },
--         inactive_tab = {
--           bg_color = "#000000"
--         },
--       }
--     },
--     modules = {
--       workspaces = {
--         enabled = false,
--       },
--       leader = {
--         enabled = false,
--       },
--       pane = {
--         enabled = false,
--       },
--       username = {
--         enabled = false,
--       },
--       hostname = {
--         enabled = false,
--       },
--       clock = {
--         enabled = false
--       },
--       cwd = {
--         enabled = false
--       },
--     },
--   }
-- )
tabline.apply_to_config(config)
sessionizer.apply_to_config(config)
return config
