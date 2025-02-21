return {
  setup = function()
    -----------------------------------------------------------------------------------
    -- Indent file
    -----------------------------------------------------------------------------------
    vim.keymap.set('n', '<leader>ii', 'gg=G``', { desc = 'Automatically [i]ndent file' })

    -- Source file lua
    vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
    vim.keymap.set("n", "<leader>x", ":.lua<CR>")
    vim.keymap.set("v", "<leader>x", ":lua<CR>")

    -- vim.keymap.set('n', '<leader><leader>x', ':luafile %<CR>', { desc = 'Source file' })

    -----------------------------------------------------------------------------------
    -- Indent files with space instead of tabs
    -----------------------------------------------------------------------------------
    vim.keymap.set('n', '<leader>i2', ':set autoindent expandtab tabstop=2 shiftwidth=2<cr>', { desc = '[I]ndent file using [2] spaces' })
    vim.keymap.set('n', '<leader>i4', ':set autoindent expandtab tabstop=4 shiftwidth=4<cr>', { desc = '[I]ndent file using [4] spaces' })

    -----------------------------------------------------------------------------------
    -- Keymaps for better default experience
    -----------------------------------------------------------------------------------
    -- See `:help vim.keymap.set()`
    vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true, desc = 'Disable space key' })

    -----------------------------------------------------------------------------------
    vim.keymap.set('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { desc = '[G]oto [D]efinition' })
    vim.keymap.set('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', { desc = '[G]oto [R]eferences' })

    vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', { desc = '[R]eplace [N]ame' })
    -----------------------------------------------------------------------------------
    -- Use leader and yank to copy to the clipboard
    -----------------------------------------------------------------------------------
    vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = '[y]ank into system clipboard' })
    vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = '[Y]ank to end of line into system clipboard' })

    -- On WSL this doesn't work with clip.exe - simply use ctrl-shift-v in INSERT mode
    if not vim.fn.has("wsl") then
      vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = '[p]aste into buffer from system clipboard' })
      vim.keymap.set("n", "<leader>P", [["+P]], { desc = '[P]aste onto new line from system clipboard' })
    end

    -----------------------------------------------------------------------------------
    -- Manually remove all trailing whitespace
    -----------------------------------------------------------------------------------
    vim.keymap.set('n', '<leader>ws', '<cmd>StripTrailingWhitespace<cr>', { desc = 'Remove trailing whitespace' })

    -----------------------------------------------------------------------------------
    -- Diagnostic keymaps
    -----------------------------------------------------------------------------------
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic hint' })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic hint' })

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

    -----------------------------------------------------------------------------------
    -- Line numbers
    -----------------------------------------------------------------------------------
    -- Toggle relative line numbers
    vim.keymap.set("n", "<leader>ll", ":set relativenumber!<CR>", { desc = '[r]elative [l]ine numbers' })

    -----------------------------------------------------------------------------------
    --- Window splits
    -----------------------------------------------------------------------------------

    vim.keymap.set("n", "<C-w>-", ":split<CR>", { desc = 'split [h]orizontally' })
    vim.keymap.set("n", "<C-w>\\", ":vsplit<CR>", { desc = 'split [v]ertically' })
  end
}
