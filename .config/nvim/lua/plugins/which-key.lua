-- Useful plugin to show you pending keybinds
return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      -- delay between pressing a key and opening which-key (milliseconds)
      -- this setting is independent of vim.opt.timeoutlen
      delay = 500,
    },
  }
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
