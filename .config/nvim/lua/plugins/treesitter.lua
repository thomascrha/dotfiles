-- Highlight, edit, and navigate code
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'main',
    build = ":TSUpdate",
    main = "nvim-treesitter", -- Sets main module to use for opts
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end

          -- check if parser exists and load it
          if not vim.treesitter.language.add(language) then
            return
          end

          -- enables syntax highlighting and other treesitter features
          vim.treesitter.start(buf, language)

          -- enables treesitter based indentation
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      local ensure_installed = {
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
      }

      local already_installed = require("nvim-treesitter").get_installed()
      local to_install = vim.iter(ensure_installed)
          :filter(function(parser)
            return not vim.tbl_contains(already_installed, parser)
          end)
          :totable()
      require("nvim-treesitter").install(to_install)
    end,
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
