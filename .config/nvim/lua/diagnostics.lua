return {
  setup = function()
    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts
    vim.diagnostic.config({
      severity_sort = true,
      virtual_text = false, -- Disable virtual text for all lines by default
      float = { border = "rounded" },
      underline = true,     -- Enable underlines for diagnostics
      signs = true,         -- Show signs in the gutter
      -- },
    })
    vim.keymap.set('n', 'D', function()
      vim.diagnostic.open_float(nil, {
        scope = 'line',
        focusable = false,
        close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter' },
      })
    end, { desc = 'Show diagnostics' })
    vim.keymap.set('n', '<leader>D', function()
      vim.diagnostic.setqflist({ bufnr = 0 })
      vim.cmd('copen')
    end, { desc = 'Diagnostics to quickfix' })
  end,
}

-- vim: set ft=lua ts=2 sts=2 sw=2 et:
