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
config.default_gui_startup_args = {'start', '--always-new-process'}

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

-- config.tab_bar_at_bottom = true

-----------------------------
--- Keybindings
-----------------------------
local act = wezterm.action
config.leader = { key = '`', mods = 'NONE', timeout_milliseconds = 1000 }
config.keys = {
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

}

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
-- local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
-- tabline.setup({
--   options = { theme = 'OneHalfDark' }
-- })
-- tabline.apply_to_config(config)

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(
  config,{
    modules = {
      workspaces = {
        enabled = false,
      },
      leader = {
        enabled = false,
      },
      pane = {
        enabled = false,
      },
      username = {
        enabled = false,
      },
      hostname = {
        enabled = false,
      },
      clock = {
        enabled = false
      },
      cwd = {
        enabled = false
      },
    },
  })

return config
