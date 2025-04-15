local wezterm = require("wezterm")

local act = wezterm.action
local config = wezterm.config_builder()

-- Enable the unix domain socket server for multiplexing
config.unix_domains = {
  {
    name = 'unix',
  },
}

-- This causes `wezterm` to act as though it was started as
-- `wezterm connect unix` by default, connecting to the unix
-- domain on startup.
-- If you prefer to connect manually, leave out this line.
config.default_gui_startup_args = { 'connect', 'unix' }

-----------------------------
--- General settings
-----------------------------
config.enable_wayland = true
-- workaround for wayland when trying to create new windows in a scaled display
-- config.default_gui_startup_args = {'start', '--always-new-process'}

config.font_size = 13
config.color_scheme = "OneHalfDark"

config.enable_tab_bar = true
config.enable_scroll_bar = false
config.window_close_confirmation = "NeverPrompt"

config.audible_bell = "Disabled"
config.font = wezterm.font("JetBrains Mono")

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

require("tabline").apply_to_config(config)
-----------------------------
--- Windows
-----------------------------
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  config.default_prog = { "wsl.exe", "-d", "Ubuntu-24.04" }
end

-----------------------------
--- Plugins
-----------------------------
-- Resurrect ------------------------------
-- local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
-- resurrect.state_manager.periodic_save({
--   interval_seconds = 60,
--   save_workspaces = true,
--   save_windows = true,
--   save_tabs = true,
-- })

-- wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)
-- print("here")
-- print("Save state dir " .. resurrect.state_manager.save_state_dir)

-- if wezterm.target_triple == "x86_64-pc-windows-msvc" then
--   resurrect.save_state_dir = "C:\\Users\\226960\\wezterm\\states\\"
-- end

-- Modal (custom modes with modal plugin)
local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")

wezterm.on("modal.enter", function(name, window, pane)
  modal.set_right_status(window, name)
  modal.set_window_title(pane, name)
end)

wezterm.on("modal.exit", function(name, window, pane)
  window:set_right_status("")
  modal.reset_window_title(pane)
end)

require("modes.resize").setup(modal)

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
}

config.leader = { key = "`", mods = "NONE", timeout_milliseconds = 1500 }
config.keys = {
  -- resize_mode,
  {
    key = "r",
    mods = "LEADER",
    action = modal.activate_mode("resize"),
  },
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
          -- mark as open
          projects[workspace_name] = true
        end
      end

      -- get projects
      for _, path in ipairs(paths) do
        -- Find git repositories in the path using git rev-parse to find repository root
        local success, stdout = wezterm.run_child_process({ "fd", "-t", "d", "-H", "^.git$", "--prune", path })

        if success then
          -- Process each .git directory found
          for git_dir in stdout:gmatch("[^\r\n]+") do
            -- Extract just the project name (last directory before .git)
            local project_name = git_dir:match(".*/([^/]+)/.git/?$")
            if project_name then
              if not projects[project_name] then
                -- closed
                projects[project_name] = false
                -- Get the full path without the .git suffix
                local project_path = git_dir:sub(1, -6) -- remove '/.git' from the end
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
              local workspace_name = string.match(choice.label, "^🟢%s+(.+)%s+%(open%s+in%s+current%s+instance%)$") or
                                     string.match(choice.label, "^(.+)%s+%(closed%)$")

              if not workspace_name then
                -- Fallback to the old pattern just in case
                workspace_name = string.match(choice.label, "^(.+)%s+%(.+%)$")
              end

              if not workspace_name then
                workspace_name = choice.label
              end

              -- We no longer need to check for workspaces in other instances
              -- as we're using the unix socket connection

              -- If it's a closed workspace
              if projects[workspace_name] == false then
                -- Switch to the workspace first
                inner_window:perform_action(
                  act.SwitchToWorkspace({
                    name = workspace_name,
                    spawn = {
                      args = { "zsh" },
                      cwd = id,
                    },
                  }),
                  inner_pane
                )

                -- -- Wait a moment for the workspace to be ready
                -- wezterm.sleep_ms(100)
                --
                -- -- Get the state file path for this workspace
                -- local state_path = resurrect.state_manager.save_state_dir .. "workspace/" .. workspace_name .. ".json"
                -- local exists = wezterm.run_child_process({ "test", "-f", state_path })
                --
                -- if exists then
                --   print("State exists for " .. workspace_name)
                --   local opts = {
                --     relative = true,
                --     restore_text = true,
                --     on_pane_restore = resurrect.tab_state.default_on_pane_restore,
                --   }
                --   local state = resurrect.state_manager.load_state(workspace_name, "workspace")
                --   resurrect.workspace_state.restore_workspace(state, opts)
                --   -- resurrect.workspace_state.restore_workspace(state, opts)
                --   -- local state = resurrect.load_state(workspace_name, "workspace")
                --   -- resurrect.workspace_state.restore_workspace(state, opts)
                -- else
                --   print("State does not exist for " .. workspace_name)
                --   -- No existing state, save initial state
                --   resurrect.save_state(resurrect.workspace_state.get_workspace_state())
                -- end
              else
                -- For workspaces open in the current instance, just switch to them
                inner_window:perform_action(
                  act.SwitchToWorkspace({
                    name = workspace_name,
                  }),
                  inner_pane
                )
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

  -- Resurrect
  -- {
  --   key = "d",
  --   mods = "LEADER",
  --   action = wezterm.action_callback(function(win, pane)
  --     resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
  --       resurrect.state_manager.delete_state(id)
  --     end, {
  --       title = "Delete State",
  --       description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
  --       fuzzy_description = "Search State to Delete: ",
  --       is_fuzzy = true,
  --     })
  --   end),
  -- },
  -- {
  --   key = "s",
  --   mods = "LEADER",
  --   action = wezterm.action_callback(function(win, pane)
  --     resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
  --     resurrect.window_state.save_window_action()
  --   end),
  -- },
  -- {
  --   key = "R",
  --   mods = "LEADER",
  --   action = wezterm.action_callback(function(win, pane)
  --     resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
  --       local type = string.match(id, "^([^/]+)") -- match before '/'
  --       id = string.match(id, "([^/]+)$") -- match after '/'
  --       id = string.match(id, "(.+)%..+$") -- remove file extention
  --       local opts = {
  --         relative = true,
  --         restore_text = true,
  --         on_pane_restore = resurrect.tab_state.default_on_pane_restore,
  --       }
  --       if type == "workspace" then
  --         local state = resurrect.state_manager.load_state(id, "workspace")
  --         resurrect.workspace_state.restore_workspace(state, opts)
  --       elseif type == "window" then
  --         local state = resurrect.state_manager.load_state(id, "window")
  --         resurrect.window_state.restore_window(pane:window(), state, opts)
  --       elseif type == "tab" then
  --         local state = resurrect.state_manager.load_state(id, "tab")
  --         resurrect.tab_state.restore_tab(pane:tab(), state, opts)
  --       end
  --     end)
  --   end),
  -- },
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
}

config.key_tables = modal.key_tables

local get_hostname = function()
  local f = io.popen ("/bin/hostname")
  local hostname = f:read("*a") or ""
  f:close()
  hostname =string.gsub(hostname, "\n$", "")
  return hostname
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end


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
end

return config
