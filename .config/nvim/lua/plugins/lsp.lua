return {
  "neovim/nvim-lspconfig",
  config = function ()
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]ename' })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode Action' })

    vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = 'Goto [D]efinition' })
    vim.keymap.set('n', '<leader>gr', require('telescope.builtin').lsp_references, { desc = 'Goto [R]eferences' })
    vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, { desc = 'Goto [i]mplementation' })
    -- vim.keymap.set('n', '<leader>g', vim.lsp.buf.type_definition, { desc = 'Type [D]efinition' })
    -- vim.keymap.set('n', '<leader>ls', require('telescope.builtin').lsp_document_symbols, { desc = '[D]ocument [S]ymbols' })
    -- vim.keymap.set('n', '<leader>lw', require('telescope.builtin').lsp_dynamic_workspace_symbols, { desc = '[W]orkspace [S]ymbols' })

    -- See `:help K` for why this keymap
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc ='Hover Documentation' })
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { desc ='Signature Documentation' })

    -- Lesser used LSP functionality
    -- vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, { desc ='[G]oto [D]eclaration' })
    -- vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { desc ='[W]orkspace [A]dd Folder' })
    -- vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, { desc ='[W]orkspace [R]emove Folder' })
    -- vim.keymap.set('n', '<leader>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, { desc = '[W]orkspace [L]ist Folders' })

  end
}
