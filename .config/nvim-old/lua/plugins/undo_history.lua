return {
  "mbbill/undotree",
  config = function()
    vim.keymap.set("n", "<leader>uu", "<cmd>UndotreeToggle<CR>", { desc = 'undo tree interface' })
  end
}
