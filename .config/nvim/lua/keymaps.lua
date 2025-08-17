return {
  setup = function()
    -- [[ Basic Keymaps ]]
    --  See `:help vim.keymap.set()`

    -- resource config
    vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>', { desc = "Resource neovim config" })
    vim.keymap.set('n', '<leader>F', vim.lsp.buf.format)

    -- Clear highlights on search when pressing <Esc> in normal mode
    --  See `:help hlsearch`
    vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

    -- Diagnostic keymaps
    -- vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
    -----------------------------------------------------------------------------------
    -- Use leader and yank to copy to the clipboard
    -----------------------------------------------------------------------------------
    vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = '[y]ank into system clipboard' })
    vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = '[Y]ank to end of line into system clipboard' })

    -- diabled arrow keys
    -- vim.keymap.set({ "n", "v" }, "<Up>", "<Nop>", { desc = "Disable <Up> arrow key" })
    -- vim.keymap.set({ "n", "v" }, "<Down>", "<Nop>", { desc = "Disable <Down> arrow key" })
    -- vim.keymap.set({ "n", "v" }, "<Left>", "<Nop>", { desc = "Disable <Left> arrow key" })
    -- vim.keymap.set({ "n", "v" }, "<Right>", "<Nop>", { desc = "Disable <Right> arrow key" })
  end,
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
