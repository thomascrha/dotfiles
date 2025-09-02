return {
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      local grug_far = require("grug-far")
      grug_far.setup({
        prefills = {
          filesFilter = "!.git/",
          flags = "--hidden",
        }
      })

      vim.keymap.set("n", "<leader>S", function()
        grug_far.toggle_instance({ instanceName = "far", staticTitle = "Find and Replace" })
      end, { desc = "Find & Replace" })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("grug-far-keybindings", { clear = true }),
        pattern = { "grug-far" },
        callback = function()
          vim.keymap.set("n", "q", function()
            grug_far.toggle_instance({ instanceName = "far", staticTitle = "Find and Replace" })
          end, { buffer = true })
        end,
      })
    end,
  },
  --     vim.keymap.set('n', '<leader>Ss', "<cmd>lua require('spectre').open()<cr>", { desc = '[S]ectre search' })
}
