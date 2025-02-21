return {
  {
    'ThePrimeagen/harpoon',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      vim.keymap.set('n', '<leader>1', "<cmd>lua require('harpoon.ui').nav_file(1)<CR>", { desc = "Go to harpoon 1" })
      vim.keymap.set('n', '<leader>2', "<cmd>lua require('harpoon.ui').nav_file(2)<CR>", { desc = "Go to harpoon 2" })
      vim.keymap.set('n', '<leader>3', "<cmd>lua require('harpoon.ui').nav_file(3)<CR>", { desc = "Go to harpoon 3" })
      vim.keymap.set('n', '<leader>4', "<cmd>lua require('harpoon.ui').nav_file(4)<CR>", { desc = "Go to harpoon 4" })
      vim.keymap.set('n', '<leader>5', "<cmd>lua require('harpoon.ui').nav_file(5)<CR>", { desc = "Go to harpoon 5" })
      vim.keymap.set('n', '<leader>6', "<cmd>lua require('harpoon.ui').nav_file(6)<CR>", { desc = "Go to harpoon 6" })
      vim.keymap.set('n', '<leader>7', "<cmd>lua require('harpoon.ui').nav_file(7)<CR>", { desc = "Go to harpoon 7" })
      vim.keymap.set('n', '<leader>8', "<cmd>lua require('harpoon.ui').nav_file(8)<CR>", { desc = "Go to harpoon 8" })
      vim.keymap.set('n', '<leader>9', "<cmd>lua require('harpoon.ui').nav_file(9)<CR>", { desc = "Go to harpoon 9" })
      vim.keymap.set('n', '<leader>ha', "<cmd>lua require('harpoon.mark').add_file()<CR>",
        { desc = "Add file to harpoon" })
      -- vim.keymap.set('n', '<leader>hh', "<cmd>:Telescope harpoon marks<CR>",
      --   { desc = "Open harpoon menu" })
      vim.keymap.set('n', '<leader>hh', "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>",
        { desc = "Open harpoon menu" })

      require("harpoon").setup({
        tabline = true,
      })

      vim.cmd('highlight! HarpoonInactive guibg=NONE guifg=#ABB2BF')
      vim.cmd('highlight! HarpoonActive guibg=NONE guifg=white')
      vim.cmd('highlight! HarpoonNumberActive guibg=NONE guifg=#61AFEF')
      vim.cmd('highlight! HarpoonNumberInactive guibg=NONE guifg=#61AFEF')
      vim.cmd('highlight! TabLineFill guibg=NONE guifg=white')
    end
  }
}
