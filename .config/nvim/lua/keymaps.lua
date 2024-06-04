return {
  setup = function()
    -----------------------------------------------------------------------------------
    -- indent file
    -----------------------------------------------------------------------------------
    vim.keymap.set('n', '<leader>ii', 'gg=G``', { desc = 'Automatically [i]ndent file' })

    -----------------------------------------------------------------------------------
    -- indent files with space instead of tabs
    -----------------------------------------------------------------------------------
    vim.keymap.set('n', '<leader>i2', ':set autoindent expandtab tabstop=2 shiftwidth=2<cr>', { desc = '[I]ndent file using [2] spaces' })
    vim.keymap.set('n', '<leader>i4', ':set autoindent expandtab tabstop=4 shiftwidth=4<cr>', { desc = '[I]ndent file using [4] spaces' })

    -----------------------------------------------------------------------------------
    -- Keymaps for better default experience
    -----------------------------------------------------------------------------------
    -- See `:help vim.keymap.set()`
    vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

    -----------------------------------------------------------------------------------
    -- use leader and yank to copy to the clipboard Primeagen
    -----------------------------------------------------------------------------------
    vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = '[y]ank into system clipboard' })
    vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = '[Y]ank to end of line into system clipboard' })

    -- on WSL this doesn't work with clip.exe - simply use ctrl-shift-v in INSET mode
    if not vim.fn.has("wsl") then
      vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = '[p]aste into buffer from system clipboard' })
      vim.keymap.set("n", "<leader>P", [["+P]], { desc = '[P]aste onto new line from system clipboard' })
    end
    -----------------------------------------------------------------------------------
    -- manually remove all training whitespace
    -----------------------------------------------------------------------------------
    vim.keymap.set('n', '<leader>ws', '<cmd>StripTrailingWhitespace<cr>', { desc = '' })

    -----------------------------------------------------------------------------------
    -- Diagnostic keymaps
    -----------------------------------------------------------------------------------
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'previous diagnostic hint' })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'next diagnostic hint' })

    -----------------------------------------------------------------------------------
    -- Spelling
    -----------------------------------------------------------------------------------
    vim.keymap.set(
      "n", "<leader>ss",
      function()
        require("telescope.builtin").spell_suggest(require('telescope.themes').get_cursor({}))
      end,
      { desc = '[s]pelling suggestions for current word' }
    )
    vim.keymap.set("n", "<leader>sa", ":setlocal spell!<CR>", { desc = '[s]pelling [a]ctivate' })
  end
}
