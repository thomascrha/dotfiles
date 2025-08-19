return {
  {
    "gbprod/yanky.nvim",
    dependencies = {
      { "kkharji/sqlite.lua" },
    },
    opts = {
      ring = { storage = "sqlite" },
    },
    keys = {
      {
        "<leader>fc",
        function()
          require("snacks").picker.yanky()
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
    },
  },
}

-- vim: set ft=lua ts=2 sts=2 sw=2 et:
