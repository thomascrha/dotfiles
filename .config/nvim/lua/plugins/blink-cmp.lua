return {
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- We're setting a custom keymap instead of using a preset
        -- This will use tab for confirmation and arrow keys for navigation
        preset = 'super-tab',
        custom = {
          ['<Down>'] = 'next_item',
          ['<Up>'] = 'prev_item',
          ['<C-Space>'] = 'toggle_completion',
        },

      },
      appearance = {
        nerd_font_variant = 'mono',
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },
      signature = { enabled = true },
    },
  }
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
