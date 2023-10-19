local wezterm = require 'wezterm'
local config = wezterm.config_builder()
wezterm.on('user-var-changed', function(window, pane, name, value)
    local overrides = window:get_config_overrides() or {}
  if name == "ZEN_MODE" then
    local incremental = value:find("+")
    local number_value = tonumber(value)
    if incremental ~= nil then
      while (number_value > 0) do
        window:perform_action(wezterm.action.IncreaseFontSize, pane)
        number_value = number_value - 1
      end
      overrides.enable_tab_bar = false
    elseif number_value < 0 then
      window:perform_action(wezterm.action.ResetFontSize, pane)
      overrides.font_size = nil
      overrides.enable_tab_bar = true
    else
      overrides.font_size = number_value
      overrides.enable_tab_bar = false
    end
  end
  window:set_config_overrides(overrides)
end)

-- makes the window transparent when in guake mode is detected
local mode = os.getenv("WEZTERM_GUAKE")
if mode == "on" then

  config.window_background_opacity = 0.9
end

config.keys = {
  {
    key = 'w',
    mods = 'CTRL',
    action = wezterm.action.CloseCurrentTab{confirm=true}
  },
  {
    key = 't',
    mods = 'CTRL',
    action = wezterm.action{SpawnTab='CurrentPaneDomain'}
  },
  {
    key = 'v',
    mods = 'CTRL',
    action = wezterm.action{PasteFrom="Clipboard"}
  },
}
config.color_scheme = 'OneHalfDark'
config.font_size = 10
config.hide_tab_bar_if_only_one_tab = true
config.enable_tab_bar = true
config.enable_scroll_bar = true
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
--  Defualt Program
--

-- config.default_prog = { '/bin/zsh', '-c', 'tmux', 'new', '-s', 'scratch', '||', 'tmux', 'a', '-t', 'scratch' }

-- config.text_background_opacity = 0.1


return config
