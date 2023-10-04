local wezterm = require 'wezterm'
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
return {
  color_scheme = 'OneHalfDark',
  font_size = 10,
  hide_tab_bar_if_only_one_tab = true,
  enable_tab_bar = true,
  enable_scroll_bar = true,
  window_close_confirmation = "NeverPrompt",
  audible_bell = 'Disabled',
  font = wezterm.font('JetBrains Mono'),
  window_padding = {
    left = 2,
    right = 2,
    top = 0,
    bottom = 0,
  },
  -- Make sure word selection stops on most punctuations.
  --
  -- Note that dot (.) & slash (/) are allowed though for
  -- easy selection of (partial) paths.
  selection_word_boundary = " \t\n{}[]()\"'`,;:@│*",

  --  Defualt Program
  --

  -- default_prog = { 'wsl.exe', '-d', 'Ubuntu-22.04', 'tmux', 'new', '-s', 'neovim', '||', 'tmux', 'a', '-t', 'neovim' }
  -- default_prog = { '/bin/zsh', '-c', 'tmux', 'new', '-s', 'scratch', '||', 'tmux', 'a', '-t', 'scratch' }
}

