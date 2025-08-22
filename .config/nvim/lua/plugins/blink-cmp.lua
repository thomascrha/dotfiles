return {
  {
    'saghen/blink.cmp',
    opts = {
      signature = { enabled = true },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        menu = {
          auto_show = true,
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
          },
        },
      }
    }
  }
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
