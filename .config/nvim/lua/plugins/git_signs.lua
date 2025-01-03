return {
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local gs = require("gitsigns")
      gs.setup({
        signs = {
          add          = { text = '│' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        signcolumn = true,
        watch_gitdir = {
          interval = 1000,
          follow_files = true
        },
        attach_to_untracked = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = 'eol',
          delay = 1000,
        },
        preview_config = {
          border = 'rounded',
          style = 'minimal',
          relative = 'cursor',
        },
      })
      -- Navigation
      vim.keymap.set('n', ']c', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, { expr = true, desc = 'next gitsigns'})

      vim.keymap.set('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, { expr = true, desc = 'previous gitsigns'})

      -- Actions

      vim.keymap.set({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>', { desc = '[h]unk [s]tage' })
      vim.keymap.set({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = '[h]unk [r]est stage'})
      vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { desc = '[S]tage buffer [h]unk' })
      vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'buffer [h]unk [u]ndo' })
      vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { desc = '[R]eset buffer [h]unk' })
      vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { desc = '[p]review [h]unk' })
      vim.keymap.set('n', '<leader>hb', function() gs.blame_line{full=true} end, { desc = '[h]unk [b]lame' })
      vim.keymap.set('n', '<leader>hd', gs.diffthis, { desc = '[d]iff [h]unk' })
      vim.keymap.set('n', '<leader>hD', function() gs.diffthis('~') end, { desc = '[D]iff whole file' })

      vim.keymap.set('n', '<leader>ho', gs.toggle_deleted, { desc = 'toggle deleted' })
      vim.keymap.set('n', '<leader>hl', gs.toggle_current_line_blame, { desc = 'toggle line blame' })

      -- Text object
      vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')



    end
  },
}
