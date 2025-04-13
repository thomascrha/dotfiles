return {
  setup = function()
    -- [[ Basic Keymaps ]]
    --  See `:help vim.keymap.set()`

    -- Source file lua
    vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
    vim.keymap.set("n", "<leader>x", ":.lua<CR>")
    vim.keymap.set("v", "<leader>x", ":lua<CR>")

    -- Clear highlights on search when pressing <Esc> in normal mode
    --  See `:help hlsearch`
    vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

    -- Diagnostic keymaps
    vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
  end,
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
