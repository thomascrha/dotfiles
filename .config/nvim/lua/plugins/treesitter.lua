-- Highlight, edit, and navigate code
return {
  {
    "romus204/tree-sitter-manager.nvim",
    dependencies = {}, -- tree-sitter CLI must be installed system-wide
    config = function()
      require("tree-sitter-manager").setup({
        ensure_installed = {
          "bash",
          "c",
          "diff",
          "html",
          "lua",
          "luadoc",
          "markdown",
          "markdown_inline",
          "query",
          "vim",
          "vimdoc",
          "yaml",
          "json",
          "javascript",
          "typescript",
          "tsx",
          "css",
          "scss",
          "rust",
          "python",
          "go",
          "java",
          "ruby",
          "php",
          "sql",
          "dockerfile",
          "git_config",
          "git_rebase",
          "gitcommit",
          "gitignore",
          "toml",
          "regex",
          "comment"
          -- "jsonc"
        },
        -- Optional: custom paths
        -- parser_dir = vim.fn.stdpath("data") .. "/site/parser",
        -- query_dir = vim.fn.stdpath("data") .. "/site/queries",
      })
    end
  },
  -- {
  --   'nvim-treesitter/nvim-treesitter',
  --   dependencies = { 'nvim-lua/plenary.nvim' },
  --   lazy = false,
  --   build = ':TSUpdate',
  -- }

}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
