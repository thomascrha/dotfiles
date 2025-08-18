return {
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>S",
        function()
          require("grug-far").toggle_instance({ instanceName = "far", staticTitle = "Find and Replace" })
        end,
        mode = "n",
        desc = "Find & Replace",
      },
    },
    opts = {
      prefills = {
        filesFilter = "!.git/",
        flags = "--hidden",
      },
    },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("grug-far-keybindings", { clear = true }),
        pattern = { "grug-far" },
        callback = function()
          vim.keymap.set("n", "q", function()
            require("grug-far").toggle_instance({ instanceName = "far", staticTitle = "Find and Replace" })
          end, { buffer = true })
        end,
      })
    end,
  },
  --     vim.keymap.set('n', '<leader>Ss', "<cmd>lua require('spectre').open()<cr>", { desc = '[S]ectre search' })
}
