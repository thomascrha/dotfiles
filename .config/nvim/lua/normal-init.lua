vim.g.mapleader = " "

require("bootstrap").run()
require("lazy").setup("plugins")
require("autocmds").setup()

require("lsp").setup()
-- require("dap").setup()
require("sets").setup()
require("keymaps").setup()

