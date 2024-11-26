vim.g.mapleader = " "

require("bootstrap").run()
require("lazy").setup("plugins")
require("autocmds").setup()

require("lsp").setup()
require("sets").setup()
require("keymaps").setup()

if vim.fn.isdirectory(vim.fn.stdpath("cache") .. "/avante") == 1 then
  require("avante_lib").load()
end

