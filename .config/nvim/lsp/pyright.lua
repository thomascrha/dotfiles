---@type vim.lsp.Config
return {
  settings = {
    python = {
      analysis = {
        extraPaths = {},
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
  on_init = function(client)
    vim.keymap.set('n', 'K', function()
      local win_found = false
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= "" then
          vim.api.nvim_win_close(win, true)
          win_found = true
        end
      end

      if win_found then
        -- Second press logic
        local cword = vim.fn.expand("<cword>")

        -- Run pydoc silently
        local pydoc_output = vim.fn.system({ "env", "PAGER=cat", "python3", "-m", "pydoc", cword })

        if vim.v.shell_error ~= 0 or pydoc_output:match("No Python documentation found") then
          vim.notify("No Python documentation found for '" .. cword .. "'", vim.log.levels.WARN)
        else
          -- Open a new tab
          vim.cmd("tabnew")
          local buf = vim.api.nvim_get_current_buf()

          -- Rename the buffer (which renames the tab).
          -- pcall prevents errors if a buffer with this exact name already exists
          pcall(vim.api.nvim_buf_set_name, buf, cword .. " Docs")

          -- Insert the text
          local lines = vim.split(pydoc_output, "\n", { plain = true })
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

          -- Set buffer options
          vim.bo[buf].buftype = "nofile"
          vim.bo[buf].bufhidden = "hide"
          vim.bo[buf].swapfile = false
          vim.bo[buf].modifiable = false

          vim.bo[buf].filetype = "python"

          -- Move cursor to the top
          vim.api.nvim_win_set_cursor(0, { 1, 0 })
        end
      else
        -- First press: Trigger the standard LSP hover information
        vim.lsp.buf.hover()
      end
    end, { desc = "LSP hover / pydoc scratch buffer on double press", silent = true })

    -- Define paths to check: first the current file's directory, then the project root
    local current_dir = vim.fn.expand("%:p:h")
    local root_dir = client.config.root_dir

    local venv_paths = {}
    if current_dir and current_dir ~= "" then
      table.insert(venv_paths, current_dir .. "/.venv")
    end
    if root_dir and root_dir ~= "" and root_dir ~= current_dir then
      table.insert(venv_paths, root_dir .. "/.venv")
    end

    local found_venv = nil

    -- Check which .venv directory exists first
    for _, venv_path in ipairs(venv_paths) do
      local f = io.open(venv_path, "r")
      if f then
        f:close()
        found_venv = venv_path
        break -- Stop at the first found virtual environment
      end
    end

    if found_venv then
      local site_packages = ""

      -- Look for site-packages directory in the virtual environment
      local python_version_cmd = "find " .. found_venv .. "/lib -type d -name 'python*' | sort | head -1"
      local handle = io.popen(python_version_cmd)
      if handle then
        local python_lib_path = handle:read("*a"):gsub("%s+$", "")
        handle:close()

        if python_lib_path ~= "" then
          site_packages = python_lib_path .. "/site-packages"

          -- Ensure the nested settings tables exist to prevent nil indexing errors
          client.config.settings = client.config.settings or {}
          client.config.settings.python = client.config.settings.python or {}
          client.config.settings.python.analysis = client.config.settings.python.analysis or {}

          -- Add site-packages to extraPaths
          client.config.settings.python.analysis.extraPaths = {
            site_packages,
          }

          vim.notify("Python virtual environment found at: " .. found_venv, vim.log.levels.INFO)
          vim.notify("Added to PYTHONPATH: " .. site_packages, vim.log.levels.INFO)
        end
      end
    end
  end,
}
