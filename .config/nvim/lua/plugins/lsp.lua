return {
  "neovim/nvim-lspconfig",
 dependencies = {
    {
      "j-hui/fidget.nvim",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
    },
    },
  config = function ()
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]ename' })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode Action' })

    vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, { desc = 'Goto [D]efinition' })
    vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, { desc ='[G]oto [D]eclaration' })
    vim.keymap.set('n', '<leader>gf', vim.lsp.buf.references, { desc = 'Goto [F]irst Reference' })
    vim.keymap.set('n', '<leader>gr', require('telescope.builtin').lsp_references, { desc = 'Goto [R]eferences' })
    vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, { desc = 'Goto [i]mplementation' })

    vim.keymap.set('n', '<leader>ls', require('telescope.builtin').lsp_document_symbols, { desc = '[D]ocument [S]ymbols' })
    vim.keymap.set('n', '<leader>lw', require('telescope.builtin').lsp_dynamic_workspace_symbols, { desc = '[W]orkspace [S]ymbols' })

    -- See `:help K` for why this keymap
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc ='Hover Documentation' })
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { desc ='Signature Documentation' })

  end
}
