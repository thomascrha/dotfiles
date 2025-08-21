return {
  setup = function()
    vim.keymap.set('n', '<leader>F', vim.lsp.buf.format, { desc = '[F]ormat current buffer' })

    -- Clear highlights on search when pressing <Esc> in normal mode
    vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

    -----------------------------------------------------------------------------------
    -- Use leader and yank to copy to the clipboard
    -----------------------------------------------------------------------------------
    vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = '[y]ank into system clipboard' })
    vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = '[Y]ank to end of line into system clipboard' })

    -- Move lines
    vim.keymap.set("n", "<C-Down>", ":m .+1<CR>==", { desc = "Move line down" })
    vim.keymap.set("n", "<C-Up>", ":m .-2<CR>==", { desc = "Move line up" })
    vim.keymap.set("v", "<C-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
    vim.keymap.set("v", "<C-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

    -- Toggle relative line numbers
    vim.keymap.set("n", "<leader>tn", function()
      if vim.wo.relativenumber then
        vim.wo.relativenumber = false
        vim.wo.number = true
      else
        vim.wo.relativenumber = true
        vim.wo.number = true
      end
    end, { desc = "Toggle relative line numbers" })

    -- center cursor on screen
    vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
    vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center cursor" })
    vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
    vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
  end,
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
