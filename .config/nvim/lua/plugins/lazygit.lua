return {
  {
    'kdheepak/lazygit.nvim',
    config = function()
      vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = 'LazyGit' })
    end,
  }
}
