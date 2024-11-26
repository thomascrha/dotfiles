return {
  "folke/which-key.nvim",
  config = function()
    require('which-key').setup({

    })
    vim.keymap.set("i", "<C-w>", "<cmd>WhichKey<cr>", { silent = true, noremap = true, desc = 'which key' })
  end
}
