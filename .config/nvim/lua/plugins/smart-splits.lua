return {
  {
    'mrjones2014/smart-splits.nvim',
    config = function ()
      local smart_spilts = require('smart-splits')
      smart_spilts.setup({
        resize_mode = {
          -- key to exit persistent resize mode
          -- quit_key = '<ESC>',
          -- keys to use for moving in resize mode
          -- in order of left, down, up' right
          resize_keys = { '<Left>', '<Down>', '<Up>', '<Right>' },
          -- set to true to silence the notifications
          -- when entering/exiting persistent resize mode
          silent = true,
          -- must be functions, they will be executed when
          -- entering or exiting the resize mode
          -- hooks = {
          --   -- Set the mode text (Like NORMAL, INSERT, etc) to RESIZE
          --   on_enter = function()
          --     vim.api.nvim_command('setlocal statusline+=%#warningmsg# RESIZE')
          --   end,
          --
          --   -- Remove the RESIZE text from the statusline
          --   on_leave = function()
          --     vim.api.nvim_command('setlocal statusline-=%#warningmsg# RESIZE')
          --   end,
          -- },
        },
      })
      -- moving between splits
      vim.keymap.set('n', '<A-Left>', require('smart-splits').move_cursor_left, { desc = 'move to [p]revious split' })
      vim.keymap.set('n', '<A-Down>', require('smart-splits').move_cursor_down, { desc = 'move to [n]ext split' })
      vim.keymap.set('n', '<A-Up>', require('smart-splits').move_cursor_up, { desc = 'move to [p]revious split' })
      vim.keymap.set('n', '<A-Right>', require('smart-splits').move_cursor_right, { desc = 'move to [n]ext split' })
      vim.keymap.set('n', '<A-\\>', require('smart-splits').move_cursor_previous, { desc = 'move to [p]revious split' })
      -- swapping buffers between windows

      vim.keymap.set('n', '<leader><leader><Left>', require('smart-splits').swap_buf_left, { desc = 'swap buffer [l]eft' })
      vim.keymap.set('n', '<leader><leader><Down>', require('smart-splits').swap_buf_down, { desc = 'swap buffer [d]own' })
      vim.keymap.set('n', '<leader><leader><Up>', require('smart-splits').swap_buf_up, { desc = 'swap buffer [u]p' })
      vim.keymap.set('n', '<leader><leader><Right>', require('smart-splits').swap_buf_right, { desc = 'swap buffer [r]ight' })

      vim.keymap.set('n', '<leader>r', require('smart-splits').start_resize_mode, { desc = 'split [h]orizontally' })

      -- create vertical spli
      vim.keymap.set('n', '<leader><leader>\\', '<cmd>vsplit<cr>', { desc = 'split [v]ertically' })
      vim.keymap.set('n', '<leader><leader>-', '<cmd>split<cr>', { desc = 'split [h]orizontally' })
      vim.keymap.set('n', '<leader><leader>q', '<cmd>q<cr>', { desc = 'close buffer' })
      -- vim.keymap.set('n', '<leader>-', require('smart-splits').split_down, { desc = 'split [h]orizontally' })

    end
  }
}
