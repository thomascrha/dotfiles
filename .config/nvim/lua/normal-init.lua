vim.g.mapleader = " "

require("bootstrap").run()
require("lazy").setup("plugins")
require("autocmds").setup()

require("sets").setup()
require("keymaps").setup()


