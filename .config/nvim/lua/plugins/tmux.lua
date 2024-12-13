return {
  -- {
  --   'alexghergh/nvim-tmux-navigation',
  --   config = function()
  --     local nvim_tmux_nav = require('nvim-tmux-navigation')
  --
  --     nvim_tmux_nav.setup {
  --       disable_when_zoomed = true -- defaults to false
  --     }
  --
  --     vim.keymap.set('n', "<A-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
  --     vim.keymap.set('n', "<A-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
  --     vim.keymap.set('n', "<A-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
  --     vim.keymap.set('n', "<A-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
  --
  --     vim.keymap.set('n', "<A-Left>", nvim_tmux_nav.NvimTmuxNavigateLeft)
  --     vim.keymap.set('n', "<A-Down>", nvim_tmux_nav.NvimTmuxNavigateDown)
  --     vim.keymap.set('n', "<A-Up>", nvim_tmux_nav.NvimTmuxNavigateUp)
  --     vim.keymap.set('n', "<A-Right>", nvim_tmux_nav.NvimTmuxNavigateRight)
  --
  --     vim.keymap.set('n', "<A-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
  --     vim.keymap.set('n', "<A-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
  --
  --   end
  -- },
  {
    'mrjones2014/smart-splits.nvim',
    config = function ()
      local smart_spilts = require('smart-splits').setup()
      -- recommended mappings
      -- resizing splits
      -- these keymaps will also accept a range,
      -- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
      -- vim.keymap.set('n', '<A-Left>', require('smart-splits').resize_left)
      -- vim.keymap.set('n', '<A-Down>', require('smart-splits').resize_down)
      -- vim.keymap.set('n', '<A-Up>', require('smart-splits').resize_up)
      -- vim.keymap.set('n', '<A-Right>', require('smart-splits').resize_right)
      -- moving between splits
      vim.keymap.set('n', '<A-Left>', require('smart-splits').move_cursor_left)
      vim.keymap.set('n', '<A-Down>', require('smart-splits').move_cursor_down)
      vim.keymap.set('n', '<A-Up>', require('smart-splits').move_cursor_up)
      vim.keymap.set('n', '<A-Right>', require('smart-splits').move_cursor_right)
      vim.keymap.set('n', '<A-\\>', require('smart-splits').move_cursor_previous)
      -- swapping buffers between windows

      vim.keymap.set('n', '<leader><leader><Left>', require('smart-splits').swap_buf_left)
      vim.keymap.set('n', '<leader><leader><Down>', require('smart-splits').swap_buf_down)
      vim.keymap.set('n', '<leader><leader><Up>', require('smart-splits').swap_buf_up)
      vim.keymap.set('n', '<leader><leader><Right>', require('smart-splits').swap_buf_right)

    end
  }
}
