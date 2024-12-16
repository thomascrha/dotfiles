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
  config.window_background_opacity = 0.9
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

config.tab_bar_at_bottom = true


-----------------------------
--- Windows
-----------------------------
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  config.default_prog = { 'wsl.exe', '-d', 'Ubuntu-22.04'}
end

-- Show which key table is active in the status area
wezterm.on('update-right-status', function(window, pane)
  local name = window:active_key_table()
  if name then
    name = 'TABLE: ' .. name
  end
  window:set_right_status(name or '')
end)
-----------------------------
--- Plugins
-----------------------------
-- Bar -----------------------------------
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(
  config,
  {
    colors = {
      tab_bar = {
        active_tab = {
          bg_color = "#000000"
        },
        inactive_tab = {
          bg_color = "#000000"
        },
      }
    },
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
  }
)
-- Resurrect ------------------------------
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
resurrect.periodic_save({
  interval_seconds = 60,
  save_workspaces = true,
  save_windows = true,
  save_tabs = true,
})

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
  resurrect.save_state_dir = "C:\\Users\\226960\\wezterm\\states\\"
end
-----------------------------
--- Keybindings
-----------------------------
local act = wezterm.action
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end

local paths = {
  "/home/tcrha/Projects",
  "/home/tcrha/dotfiles"
}

config.leader = { key = '`', mods = 'NONE', timeout_milliseconds = 1500 }
config.keys = {
  --
  -- CTRL+SHIFT+Space, followed by 'r' will put us in resize-pane
  -- mode until we cancel that mode.
  {
    key = 'R',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
      name = 'resize_pane',
      one_shot = false,
    },
  },

  -- CTRL+SHIFT+Space, followed by 'a' will put us in activate-pane
  -- mode until we press some other key or until 1 second (1000ms)
  -- of time elapses
  -- {
  --   key = 'a',
  --   mods = 'LEADER',
  --   action = act.ActivateKeyTable {
  --     name = 'activate_pane',
  --     timeout_milliseconds = 1000,
  --   },
  -- },
  -- Add the key to activate window mode
  -- {
  --   key = 'alt',
  --   action = act.ActivateKeyTable {
  --     name = 'window_mode',
  --     one_shot = false,
  --     timeout_milliseconds = 1000,
  --   },
  -- },
  -- {
  --   -- make ctrl+` open input the text ` (backtick)
  --   key = "`",
  --   mods = "CTRL+SHIFT",
  --   action = act.SendString("`")
  -- },
  {
    key = "/",
    mods = "LEADER",
    -- action = workspace_switcher.switch_workspace(),
    action = wezterm.action_callback(function(win, pane)
      local workspaces = wezterm.mux.get_workspace_names()
      if #workspaces == 0 then
        return
      end

      local projects = {}
      local choices = {}
      local active_workspace = wezterm.mux.get_active_workspace()

      for _, workspace_name in ipairs(workspaces) do
        if workspace_name == active_workspace then
          print("Active workspace: " .. workspace_name)
        else
          table.insert(choices, {
            label = workspace_name .. ' (open)',
            id = workspace_name,
          })
          -- open
          projects[workspace_name] = true
        end
      end

      -- get projects
      for _, path in ipairs(paths) do
        -- Find git repositories in the path using git rev-parse to find repository root
        print("Searching for git repositories in " .. path)
        local success, stdout = wezterm.run_child_process({"fd", "-t", "d", "-H", "^.git$", "--prune", path})

        if success then
                   -- Process each .git directory found
          for git_dir in stdout:gmatch("[^\r\n]+") do
            -- Extract just the project name (last directory before .git)
            local project_name = git_dir:match(".*/([^/]+)/.git/?$")
            print("Found project: " .. project_name)
            if project_name then
                if projects[project_name] then
                  print("Project already open")
                else
                  -- closed
                  projects[project_name] = false
                  -- Get the full path without the .git suffix
                  local project_path = git_dir:sub(1, -6)  -- remove '/.git' from the end
                  table.insert(choices, {
                    label = project_name .. ' (closed)',
                    id = project_path,
                  })
              end
            end
          end
        end
      end

      win:perform_action(
        act.InputSelector {
          fuzzy_description = '⚠️  Select workspace to switch to: ',
          title = '⚠️  Select workspace to switch to: ',
          fuzzy = true,
          choices = choices,
          action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
            if id then
              -- remove the '(open)' or '(closed)' from the label
              label = string.match(label, "^(.+) %(.+%)$")

              -- First switch to the workspace
              inner_window:perform_action(
                act.SwitchToWorkspace {
                  name = label,
                  spawn = {
                    args = { 'zsh' },
                    cwd = id,
                  },
                },
                inner_pane
              )

              -- closed
              if projects[label] == false then
                -- Wait a moment for the workspace to be ready
                wezterm.sleep_ms(100)

                -- Get the state file path for this workspace
                local state_path = resurrect.save_state_dir .. "workspace/" .. label .. ".json"
                local exists = wezterm.run_child_process({"test", "-f", state_path})

                if exists then
                  print("State exists")
                  local opts = {
                    -- do in the current window
                    -- window = win:mux_window(), -- THIS IS THE NEW PART
                    relative = true,
                    restore_text = true,
                    on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                  }
                  local state = resurrect.load_state(label, "workspace")
                  resurrect.workspace_state.restore_workspace(state, opts)
                else
                  print("State does not exist")
                  -- No existing state, save initial state
                  resurrect.save_state(resurrect.workspace_state.get_workspace_state())
                end
              end
              -- if open then
              --   inner_window:perform_action(
              --     act.SwitchToWorkspace {
              --       name = label,
              --     },
              --     inner_pane
              --   )
              -- else
              --
              -- end

            end
          end),
        },
        pane
      )
    end),
  },

  -- This will create a new split and run your default program inside it
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = false }},
  { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollByLine(-1) },
  { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollByLine(1) },
  { key = 'PageUp', action = act.ScrollByPage(-0.8) },
  { key = 'PageDown', action = act.ScrollByPage(0.8) },
  -- { key = 'u', mods = "LEADER", action = wezterm.plugin.update_all() },
  { key = "-", mods = "LEADER", action = act.SplitVertical { domain="CurrentPaneDomain" }},
  { key = "\\", mods = "LEADER", action = act.SplitHorizontal { domain="CurrentPaneDomain" }},
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
    key = 'q',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      local workspaces = wezterm.mux.get_workspace_names()
      if #workspaces == 0 then
        return
      end

      local choices = {}
      local active_workspace = wezterm.mux.get_active_workspace()

      for _, workspace_name in ipairs(workspaces) do
        table.insert(choices, {
          label = workspace_name .. (workspace_name == active_workspace and ' (active)' or ''),
          id = workspace_name,
        })
      end

      window:perform_action(
        act.InputSelector {
          description = '⚠️  Select workspace to delete',
          title = '⚠️  Select workspace to delete',
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
        },
        pane
      )
    end),
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
  {
    key = "LeftArrow",
    mods = "ALT",
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = "LeftArrow", mods = 'ALT' },
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
          SendKey = { key = "RightArrow", mods = 'ALT' },
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
          SendKey = { key = "UpArrow", mods = 'ALT' },
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
          SendKey = { key = "DownArrow", mods = 'ALT' },
        }, pane)
      else
        win:perform_action({ ActivatePaneDirection = "Down" }, pane)
      end
    end),
  },
}
config.key_tables = {
  -- Defines the keys that are active in our resize-pane mode.
  -- Since we're likely to want to make multiple adjustments,
  -- we made the activation one_shot=false. We therefore need
  -- to define a key assignment for getting out of this mode.
  -- 'resize_pane' here corresponds to the name="resize_pane" in
  -- the key assignments above.
  resize_pane = {
    { key = 'LeftArrow', action = act.AdjustPaneSize { 'Left', 15 } },
    { key = 'h', action = act.AdjustPaneSize { 'Left', 15 } },

    { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 15 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 15 } },

    { key = 'UpArrow', action = act.AdjustPaneSize { 'Up', 15 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 15 } },

    { key = 'DownArrow', action = act.AdjustPaneSize { 'Down', 15 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 15 } },

    -- Cancel the mode by pressing escape
    { key = 'Escape', action = 'PopKeyTable' },
  },
}

return config

