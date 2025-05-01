local wezterm = require("wezterm")

local act = wezterm.action
local config = wezterm.config_builder()

-- Enable the unix domain socket server for multiplexing
config.unix_domains = {
  {
    name = "windows",
  },
}

-- This causes `wezterm` to act as though it was started as
-- `wezterm connect unix` by default, connecting to the unix
-- domain on startup.
-- If you prefer to connect manually, leave out this line.
-- config.default_gui_startup_args = { "connect", "unix" }

-----------------------------
--- General settings
-----------------------------
config.enable_wayland = true
-- workaround for wayland when trying to create new windows in a scaled display
-- config.default_gui_startup_args = {'start', '--always-new-process'}

config.font_size = 12
config.color_scheme = "OneHalfDark"

config.enable_tab_bar = true
config.enable_scroll_bar = false
config.window_close_confirmation = "NeverPrompt"

config.audible_bell = "Disabled"
config.font = wezterm.font({
  family = "JetBrains Mono",
})

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Make sure word selection stops on most punctuations.
--
-- Note that dot (.) & slash (/) are allowed though for
-- easy selection of (partial) paths.
config.selection_word_boundary = " \t\n{}[]()''`,;:@│*"

-- Store workspaces in order of creation
local workspace_order = {}

-- Track workspace creation to maintain order
wezterm.on("window-config-reloaded", function(window, pane)
  local current_workspace = window:active_workspace()
  -- Add to order list if not already there
  local found = false
  for _, name in ipairs(workspace_order) do
    if name == current_workspace then
      found = true
      break
    end
  end
  if not found then
    table.insert(workspace_order, current_workspace)
  end
end)

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
local theme = wezterm.color.get_builtin_schemes()[config.color_scheme]
-- Custom tab bar with workspace name on the left side
wezterm.on("update-status", function(window, pane)
  -- Get the current workspace name
  local workspace = window:active_workspace()

  -- Get all available workspaces (alphabetically sorted by default)
  local all_workspaces_set = {}
  for _, name in ipairs(wezterm.mux.get_workspace_names()) do
    all_workspaces_set[name] = true
  end

  -- Create ordered list that preserves creation order
  local all_workspaces = {}

  -- First add workspaces we've seen before in their original order
  for _, name in ipairs(workspace_order) do
    if all_workspaces_set[name] then
      table.insert(all_workspaces, name)
      all_workspaces_set[name] = nil -- Mark as processed
    end
  end

  -- Then add any new workspaces we haven't tracked yet
  for name, _ in pairs(all_workspaces_set) do
    table.insert(all_workspaces, name)
    table.insert(workspace_order, name) -- Add to our tracking list
  end

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
-----------------------------
--- Windows
-----------------------------
-----------------------------
--- Windows
-----------------------------
-- if wezterm.target_triple == "x86_64-pc-windows-msvc" then
--   config.default_prog = { "wsl.exe", "-d", "Ubuntu-24.04" }
-- end

config.wsl_domains = {
  {
    -- The name of this specific domain.  Must be unique amonst all types
    -- of domain in the configuration file.
    name = 'WSL:Ubuntu-24.04',

    -- The name of the distribution.  This identifies the WSL distribution.
    -- It must match a valid distribution from your `wsl -l -v` output in
    -- order for the domain to be useful.
    distribution = 'Ubuntu-24.04',

    -- The username to use when spawning commands in the distribution.
    -- If omitted, the default user for that distribution will be used.

    -- username = "hunter",

    -- The current working directory to use when spawning commands, if
    -- the SpawnCommand doesn't otherwise specify the directory.

    -- default_cwd = "/tmp"

    -- The default command to run, if the SpawnCommand doesn't otherwise
    -- override it.  Note that you may prefer to use `chsh` to set the
    -- default shell for your user inside WSL to avoid needing to
    -- specify it here

    -- default_prog = {"fish"}
  },
}

-----------------------------
--- Plugins
-----------------------------
-- Zombie
-- local zombie = wezterm.plugin.require("https://github.com/thomascrha/zombie.wezterm")
-- zombie.save_workspace()
--
-- -- Modal (custom modes with modal plugin)
-- local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
--
-- wezterm.on("modal.enter", function(name, window, pane)
--   window:set_right_status("")
--   modal.set_right_status(window, name)
--   modal.set_window_title(pane, name)
-- end)
--
-- wezterm.on("modal.exit", function(name, window, pane)
--   window:set_right_status("")
--   modal.reset_window_title(pane)
-- end)
--
-- require("modes.resize").setup(modal)

-----------------------------
--- Keybindings
-----------------------------
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == "true"
end

local paths = {
  "/home/tcrha/Projects",
  "/home/tcrha/dotfiles",
  "\\\\wsl.localhost\\Ubuntu-24.04\\home\\tcrha\\qbe",
  "\\\\wsl.localhost\\Ubuntu-24.04\\home\\tcrha\\dotfiles",
}
config.leader = { key = "`", mods = "NONE", timeout_milliseconds = 1500 }
config.keys = {
  -- resize_mode,
  -- {
  --   key = "r",
  --   mods = "LEADER",
  --   action = modal.activate_mode("resize"),
  -- },
  {
    key = "`",
    mods = "ALT",
    action = wezterm.action.SendString("`"),
  },
  {
    key = "/",
    mods = "LEADER",
    -- action = workspace_switcher.switch_workspace(),
    action = wezterm.action_callback(function(win, pane)
      -- Get list of workspaces in current wezterm instance
      local workspaces = wezterm.mux.get_workspace_names()
      if #workspaces == 0 then
        return
      end

      local projects = {}
      local open_choices = {}
      local closed_choices = {}
      local active_workspace = wezterm.mux.get_active_workspace()

      -- We no longer need to check for workspaces in other processes
      -- as we're using the unix socket connection

      -- Process current instance workspaces first
      for _, workspace_name in ipairs(workspaces) do
        if workspace_name == active_workspace then
          print("Active workspace: " .. workspace_name)
        else
          table.insert(open_choices, {
            label = "🟢 " .. workspace_name .. " (open in current instance)",
            id = workspace_name,
          })
          -- check if the default workspace ixists and if it does remove it
          if workspace_name ~= "default" then
            projects[workspace_name] = true
          end
          -- mark as open
        end
      end

            -- get projects
      for _, path in ipairs(paths) do
        print(path)
        local success, stdout = wezterm.run_child_process({ "fd", "-t", "d", "-H", "^.git$", "--prune", path })
        print(stdout)
        if success then
          -- Process each .git directory found
          for git_dir in stdout:gmatch("[^\r\n]+") do
            -- Handle both Unix and Windows paths
            local project_name = git_dir:match(".*/([^/]+)/.git/?$") or git_dir:match(".*\\([^\\]+)\\.git\\?$")
            if project_name then
              if not projects[project_name] then
                projects[project_name] = false
                -- Handle both Unix and Windows paths for project_path
                local project_path
                if git_dir:find("%.git/?$") then
                  project_path = git_dir:sub(1, -6) -- remove '/.git' from the end
                else
                  project_path = git_dir:sub(1, -5) -- remove '\.git' from the end
                end
                table.insert(closed_choices, {
                  label = project_name .. " (closed)",
                  id = project_path,
                })
              end
            end
          end
        end
      end

      -- Combine choices with open workspaces at the top
      local choices = {}
      for _, choice in ipairs(open_choices) do
        table.insert(choices, choice)
      end
      for _, choice in ipairs(closed_choices) do
        table.insert(choices, choice)
      end

      win:perform_action(
        act.InputSelector({
          fuzzy_description = "⚠️  Select workspace to switch to: ",
          title = "⚠️  Select workspace to switch to: ",
          fuzzy = true,
          choices = choices,
          action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
            if id then
              -- Find the original choice to get metadata
              local choice = nil
              for _, c in ipairs(choices) do
                if c.id == id then
                  choice = c
                  break
                end
              end

              if not choice then
                return
              end

              -- Remove emoji prefix if present
              local workspace_name = string.match(choice.label, "^🟢%s+(.+)%s+%(open%s+in%s+current%s+instance%)$")
                or string.match(choice.label, "^(.+)%s+%(closed%)$")
                or string.match(choice.label, "^(.+)%s+%(.+%)$")

              if not workspace_name then
                workspace_name = choice.label
              end

              -- If it's a closed workspace
              -- Switch to the workspace first
              if projects[workspace_name] == false then
                inner_window:perform_action(
                  act.SwitchToWorkspace({
                    name = workspace_name,
                    spawn = {
                      args = { "wsl.exe", "-d", "Ubuntu-24.04" },
                      cwd = id,
                    },
                  }),
                  inner_pane
                )
              else
                -- For workspaces open in the current instance, just switch to them
                inner_window:perform_action(
                  act.SwitchToWorkspace({
                    name = workspace_name,
                  }),
                  inner_pane
                )
              end
            end
          end),
        }),
        pane
      )
    end),
  },

  -- This will create a new split and run your default program inside it
  { key = "X", mods = "LEADER", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
  { key = "UpArrow", mods = "SHIFT", action = act.ScrollByLine(-1) },
  { key = "DownArrow", mods = "SHIFT", action = act.ScrollByLine(1) },
  { key = "PageUp", action = act.ScrollByPage(-0.8) },
  { key = "PageDown", action = act.ScrollByPage(0.8) },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  -- { key = 'u', mods = 'LEADER', action = wezterm.plugin.update_all() },
  { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "Q", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
  -- goto tabs via index
  { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
  { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
  { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
  { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
  { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
  { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
  { key = "9", mods = "LEADER", action = act.ActivateTab(8) },
  {
    key = ",",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = "Enter new name for tab",
      -- initial_value = 'My Tab Name',
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
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
    key = "D",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      local workspaces = wezterm.mux.get_workspace_names()
      if #workspaces == 0 then
        return
      end

      local choices = {}
      local active_workspace = wezterm.mux.get_active_workspace()

      for _, workspace_name in ipairs(workspaces) do
        table.insert(choices, {
          label = workspace_name .. (workspace_name == active_workspace and " (active)" or ""),
          id = workspace_name,
        })
      end

      window:perform_action(
        act.InputSelector({
          description = "⚠️  Select workspace to delete",
          title = "⚠️  Select workspace to delete",
          choices = choices,
          action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
            if id then
              if id == active_workspace then
                return
              end
              local success, stdout = wezterm.run_child_process({ "wezterm", "cli", "list", "--format=json" })

              if success then
                local json = wezterm.json_parse(stdout)
                if not json then
                  return
                end

                local workspace_panes = {}
                for _, p in ipairs(json) do
                  if p.workspace == id then
                    table.insert(workspace_panes, p)
                  end
                end

                for _, p in ipairs(workspace_panes) do
                  wezterm.run_child_process({ "wezterm", "cli", "kill-pane", "--pane-id=" .. p.pane_id })
                end
              else
              end
            end
          end),
        }),
        pane
      )
    end),
  },

  {
    key = "n",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = wezterm.format({
        { Attribute = { Intensity = "Bold" } },
        { Foreground = { AnsiColor = "Fuchsia" } },
        { Text = "Enter name for new workspace" },
      }),
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            act.SwitchToWorkspace({
              name = line,
            }),
            pane
          )
        end
      end),
    }),
  },
  {
    key = "LeftArrow",
    mods = "ALT",
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = "LeftArrow", mods = "ALT" },
        }, pane)
      else
        win:perform_action({ ActivatePaneDirection = "Left" }, pane)
      end
    end),
  },
  {
    key = "RightArrow",
    mods = "ALT",
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = "RightArrow", mods = "ALT" },
        }, pane)
      else
        win:perform_action({ ActivatePaneDirection = "Right" }, pane)
      end
    end),
  },
  {
    key = "UpArrow",
    mods = "ALT",
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = "UpArrow", mods = "ALT" },
        }, pane)
      else
        win:perform_action({ ActivatePaneDirection = "Up" }, pane)
      end
    end),
  },
  {
    key = "DownArrow",
    mods = "ALT",
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = "DownArrow", mods = "ALT" },
        }, pane)
      else
        win:perform_action({ ActivatePaneDirection = "Down" }, pane)
      end
    end),
  },

  -- Workspace switching with Alt+number keys
  {
    key = "1",
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      local workspaces = workspace_order
      if #workspaces >= 1 then
        win:perform_action(act.SwitchToWorkspace({ name = workspaces[1] }), pane)
      end
    end),
  },
  {
    key = "2",
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      local workspaces = workspace_order
      if #workspaces >= 2 then
        win:perform_action(act.SwitchToWorkspace({ name = workspaces[2] }), pane)
      end
    end),
  },
  {
    key = "3",
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      local workspaces = workspace_order
      if #workspaces >= 3 then
        win:perform_action(act.SwitchToWorkspace({ name = workspaces[3] }), pane)
      end
    end),
  },
  {
    key = "4",
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      local workspaces = workspace_order
      if #workspaces >= 4 then
        win:perform_action(act.SwitchToWorkspace({ name = workspaces[4] }), pane)
      end
    end),
  },
  {
    key = "5",
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      local workspaces = workspace_order
      if #workspaces >= 5 then
        win:perform_action(act.SwitchToWorkspace({ name = workspaces[5] }), pane)
      end
    end),
  },
  {
    key = "6",
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      local workspaces = workspace_order
      if #workspaces >= 6 then
        win:perform_action(act.SwitchToWorkspace({ name = workspaces[6] }), pane)
      end
    end),
  },
  {
    key = "7",
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      local workspaces = workspace_order
      if #workspaces >= 7 then
        win:perform_action(act.SwitchToWorkspace({ name = workspaces[7] }), pane)
      end
    end),
  },
  {
    key = "8",
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      local workspaces = workspace_order
      if #workspaces >= 8 then
        win:perform_action(act.SwitchToWorkspace({ name = workspaces[8] }), pane)
      end
    end),
  },
  {
    key = "9",
    mods = "CTRL",
    action = wezterm.action_callback(function(win, pane)
      local workspaces = workspace_order
      if #workspaces >= 9 then
        win:perform_action(act.SwitchToWorkspace({ name = workspaces[9] }), pane)
      end
    end),
  },
}

-- config.key_tables = modal.key_tables

local get_hostname = function()
  local f = io.popen("/bin/hostname")
  local hostname = f:read("*a") or ""
  f:close()
  hostname = string.gsub(hostname, "\n$", "")
  return hostname
end

local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- Current overflows
-- oni.lua
--  config.font_size
--
-- golem.lua
--  config.font_size
--
-- check if file exists $HOSTNAME.lua in wezterm config dir and apply the config
hostname_path = wezterm.config_dir .. "/" .. get_hostname() .. ".lua"
if file_exists(hostname_path) then
  local host_config = require(get_hostname())
  if host_config then
    host_config.apply_to_config(config)
  end
end

-----------------------------
--- Guake mode
-----------------------------
-- makes the window transparent when in guake mode is detected
local mode = os.getenv("WEZTERM_GUAKE")
if mode == "on" then
  config.window_background_opacity = 0.9
  config.font_size = config.font_size - 1

  config.font = wezterm.font({
    family = "JetBrains Mono",
    harfbuzz_features = { "calt=0" },
  })
end

return config

