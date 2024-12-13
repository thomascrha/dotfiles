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

-----------------------------
--- Plugins
-----------------------------
-- Bar -----------------------------------
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")

-- Smart Splits ---------------------------
-- local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')
-- Smart Workspace Switcher --------------
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

-- Resurrect ------------------------------
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local resurrect_event_listeners = {
  "resurrect.error",
  "resurrect.save_state.finished",
}
resurrect.periodic_save()
-- -- Saves the state whenever I select a workspace
-- wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
--   local workspace_state = resurrect.workspace_state
--   resurrect.save_state(workspace_state.get_workspace_state())
-- end)
-- -- loads the state whenever I create a new workspace
-- wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
--   local workspace_state = resurrect.workspace_state
--
--   workspace_state.restore_workspace(resurrect.load_state(label, "workspace"), {
--     window = window,
--     relative = true,
--     restore_text = true,
--     on_pane_restore = resurrect.tab_state.default_on_pane_restore,
--   })
-- end)

-- local is_periodic_save = false
-- wezterm.on("resurrect.periodic_save", function()
--   is_periodic_save = true
-- end)
-- for _, event in ipairs(resurrect_event_listeners) do
--   wezterm.on(event, function(...)
--     if event == "resurrect.save_state.finished" and is_periodic_save then
--       is_periodic_save = false
--       return
--     end
--     local args = { ... }
--     local msg = event
--     for _, v in ipairs(args) do
--       msg = msg .. " " .. tostring(v)
--     end
--   end)
-- end

-- Modal ---------------------------------
-- local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")

-- Sessionizer ---------------------------
local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")

sessionizer.config.paths = {
  "/home/tcrha/qbe",
  "/home/tcrha/Projects",
  "/home/tcrha/dotfiles"
}

-----------------------------
--- Keybindings
-----------------------------
local act = wezterm.action
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end
config.leader = { key = '`', mods = 'NONE', timeout_milliseconds = 1500 }
config.keys = {
  {
    -- make ctrl+` open input the text ` (backtick)
    key = "`",
    mods = "ALT",
    action = act.SendString("`")
  },
  {
    key = "t",
    mods = "LEADER",
    action = wezterm.action_callback(function(win, pane)
      local paths = {
        "/home/tcrha/Projects",
        "/home/tcrha/dotfiles"
      }

      local choices = {}
      for _, path in ipairs(paths) do
        -- Find git repositories in the path using git rev-parse to find repository root
        local success, stdout = wezterm.run_child_process({
          "find",
          path,
          "-name", ".git",
          "-type", "d",
          "-prune"
        })

        if success then
          -- Process each .git directory found
          for git_dir in stdout:gmatch("[^\r\n]+") do
            -- Get the parent directory of the .git folder (the repository root)
            local project_path = git_dir:gsub("/.git$", "")
            -- Get the project name from the path
            local project_name = project_path:match(".*/(.+)$")
            if project_name then
              table.insert(choices, {
                label = project_name,
                id = project_path
              })
            end
          end
        end
      end

      if #choices == 0 then
        wezterm.log_info("No git repositories found")
        return
      end

      -- Show the selector
      win:perform_action(
        act.InputSelector {
          title = "Select Project",
          choices = choices,
          action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
            print(inner_window, inner_pane, id, label)
            if id then
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

              -- Wait a moment for the workspace to be ready
              wezterm.sleep_ms(100)

              -- Get the state file path for this workspace
              local state_path = resurrect.get_state_path(label, "workspace")
              local exists = wezterm.run_child_process({"test", "-f", state_path})

              if exists then
                -- State exists, load and restore it
                local state = resurrect.load_state(label, "workspace")
                resurrect.workspace_state.restore_workspace(state, {
                  window = inner_window,
                  relative = true,
                  restore_text = true,
                  on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                })
              else
                -- No existing state, save initial state
                resurrect.save_state(resurrect.workspace_state.get_workspace_state())
              end
            end
          end),
        },
        pane
      )
    end),
  },
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

  -- This will create a new split and run your default program inside it
  { key = 'x', mods = 'LEADER', action = wezterm.action.CloseCurrentPane { confirm = false }},
  { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollByLine(-1) },
  { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollByLine(1) },
  { key = 'PageUp', action = act.ScrollByPage(-0.8) },
  { key = 'PageDown', action = act.ScrollByPage(0.8) },

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
  -- {
  --   key = "LeftArrow",
  --   mods = "ALT",
  --   action = wezterm.action_callback(function(win, pane)
  --     if is_vim(pane) then
  --       -- pass the keys through to vim/nvim
  --       win:perform_action({
  --         SendKey = { key = "LeftArrow", mods = 'ALT' },
  --       }, pane)
  --     else
  --       win:perform_action({ AdjustPaneSize = { direction = "Left", amount = 10 } }, pane)
  --     end
  --   end),
  -- },
  -- {
  --   key = "RightArrow",
  --   mods = "ALT",
  --   action = wezterm.action_callback(function(win, pane)
  --     if is_vim(pane) then
  --       -- pass the keys through to vim/nvim
  --       win:perform_action({
  --         SendKey = { key = "RightArrow", mods = 'ALT' },
  --       }, pane)
  --     else
  --       win:perform_action({ AdjustPaneSize = { direction = "Right", amount = 10 } }, pane)
  --     end
  --   end),
  -- },
  -- {
  --   key = "UpArrow",
  --   mods = "ALT",
  --   action = wezterm.action_callback(function(win, pane)
  --     if is_vim(pane) then
  --       -- pass the keys through to vim/nvim
  --       win:perform_action({
  --         SendKey = { key = "UpArrow", mods = 'ALT' },
  --       }, pane)
  --     else
  --       win:perform_action({ AdjustPaneSize = { direction = "Up", amount = 10 } }, pane)
  --     end
  --   end),
  -- },
  -- {
  --   key = "DownArrow",
  --   mods = "ALT",
  --   action = wezterm.action_callback(function(win, pane)
  --     if is_vim(pane) then
  --       -- pass the keys through to vim/nvim
  --       win:perform_action({
  --         SendKey = { key = "DownArrow", mods = 'ALT' },
  --       }, pane)
  --     else
  --       win:perform_action({ AdjustPaneSize = { direction = "Down", amount = 10 } }, pane)
  --     end
  --   end),
  -- }
}

-- local function split_nav(resize_or_move, key)
--   return {
--     key = key .. 'Arrow',
--     mods = resize_or_move == 'resize' and 'META' or 'CTRL',
--     action = w.action_callback(function(win, pane)
--       if is_vim(pane) then
--         -- pass the keys through to vim/nvim
--         win:perform_action({
--           SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
--         }, pane)
--       else
--         if resize_or_move == 'resize' then
--           win:perform_action({ AdjustPaneSize = { key, 10 } }, pane)
--         else
--           win:perform_action({ ActivatePaneDirection = key }, pane)
--         end
--       end
--     end),
--   }
-- end
--
-- config.keys.upd
--   keys = {
--     -- move between split panes
--     split_nav('move', 'Left'),
--     split_nav('move', 'Down'),
--     split_nav('move', 'Up'),
--     split_nav('move', 'Right'),
--     -- resize panes
--     split_nav('resize', 'Left'),
--     split_nav('resize', 'Down'),
--     split_nav('resize', 'Up'),
--     split_nav('resize', 'Left'),
--   },
-- }
-----------------------------
-- Load plugins
-----------------------------
-- Must be the last line
workspace_switcher.apply_to_config(config)
resurrect.periodic_save()
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
-- you can put the rest of your Wezterm config here
-- smart_splits.apply_to_config(config, {
--   -- the default config is here, if you'd like to use the default keys,
--   -- you can omit this configuration table parameter and just use
--   -- smart_splits.apply_to_config(config)
--
--   -- directional keys to use in order of: left, down, up, right
--   direction_keys = { 'LeftArrow', 'DownArrow', 'UpArrow', 'RightArrow' },
--
--   -- modifier keys to combine with direction_keys
--   modifiers = {
--     move = 'ALT', -- modifier to use for pane movement, e.g. CTRL+h to move left
--     resize = 'ALT', -- modifier to use for pane resize, e.g. ALT+h to resize to the left
--   },
--   -- log level to use: info, warn, error
--   log_level = 'info'
-- })
sessionizer.apply_to_config(config)

return config
--
-- return {
--   config = config,
--   keys = {
--     -- move between split panes
--     split_nav('move', 'h'),
--     split_nav('move', 'j'),
--     split_nav('move', 'k'),
--     split_nav('move', 'l'),
--     -- resize panes
--     split_nav('resize', 'h'),
--     split_nav('resize', 'j'),
--     split_nav('resize', 'k'),
--     split_nav('resize', 'l'),
--   },
-- }
