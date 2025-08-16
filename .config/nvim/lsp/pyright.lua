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
    -- Try to find .venv in the project root
    local root_dir = client.config.root_dir
    if root_dir then
      local venv_path = root_dir .. "/.venv"
      local site_packages = ""

      -- Check if .venv directory exists
      local f = io.open(venv_path, "r")
      if f then
        f:close()

        -- Look for site-packages directory in the virtual environment
        local python_version_cmd = "find " .. venv_path .. "/lib -type d -name 'python*' | sort | head -1"
        local handle = io.popen(python_version_cmd)
        if handle then
          local python_lib_path = handle:read("*a"):gsub("%s+$", "")
          handle:close()

          if python_lib_path ~= "" then
            site_packages = python_lib_path .. "/site-packages"

            -- Add site-packages to extraPaths
            client.config.settings.python.analysis.extraPaths = {
              site_packages,
            }

            vim.notify("Python virtual environment found at: " .. venv_path, vim.log.levels.INFO)
            vim.notify("Added to PYTHONPATH: " .. site_packages, vim.log.levels.INFO)
          end
        end
      end
    end
    return true
  end,
}
