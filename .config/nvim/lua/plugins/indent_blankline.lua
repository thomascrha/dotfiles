return {
  {
    "lukas-reineke/indent-blankline.nvim",
    dependencies = { "axelf4/vim-strip-trailing-whitespace" },
    config = function()
      local highlight = {
        "CursorColumn",
        "Whitespace",
      }
      require("ibl").setup({
        indent = { highlight = highlight, char = "" },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      })
    end,
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
