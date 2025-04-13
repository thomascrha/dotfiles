return {
  "mbbill/undotree",
  config = function()
    vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { desc = "undo tree interface" })
  end,
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
