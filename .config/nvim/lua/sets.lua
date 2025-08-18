return {
  setup = function()
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    -- Make line numbers default
    vim.wo.number = true

    -- set mouse mode (all modes)
    vim.o.mouse = "a"

    -- Search
    -- ignorecase during search
    vim.o.ignorecase = true
    -- if search has capital match case
    vim.o.smartcase = true
    -- don"t highlight s:map <Up> <Nop>
    vim.o.hlsearch = false
    vim.o.incsearch = true

    -- wrap lines
    vim.o.wrap = true

    -- Tabs
    -- tab size options
    vim.o.tabstop = 4
    vim.o.shiftwidth = 4
    vim.o.softtabstop = 4

    -- convert tabs to spaces
    vim.o.expandtab = true
    vim.o.smartindent = true

    -- numbers
    vim.o.relativenumber = true

    -- for god sake stop the rining
    vim.o.errorbells = false

    -- turn off the backup rubbish
    vim.o.swapfile = false
    vim.o.backup = false

    -- set termguicolors to enable highlight groups
    vim.o.termguicolors = true

    -- Give more space for displaying messages.
    vim.o.cmdheight = 1

    -- Decrease update time
    vim.wo.signcolumn = "yes"

    -- Save undo history
    vim.o.undofile = true
    vim.o.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"

    -- scrolling padding
    vim.o.scrolloff = 8

    --  spelling
    -- vim.o.spell = true
    vim.o.spelloptions = "camel"

    -- enable current line highlighting
    vim.o.cursorline = true

    -- make splits open to down and right
    vim.o.splitbelow = true
    vim.o.splitright = true

    vim.g.copilot_assume_mapped = true

    -- Nice looking file diff
    vim.o.fillchars = "diff:/"

    -- Show hidden characters like tabs, trailing spaces, etc.
    vim.o.list = true
    vim.o.listchars = "tab:→ ,trail:·,extends:▶,precedes:◀,nbsp:␣"

    vim.o.mousemodel = "extend"

    vim.opt.winborder = "rounded"

    -- prevent the built-in vim.lsp.completion autotrigger from selecting the first item
    vim.opt.completeopt = { "menuone", "noselect", "popup" }
  end,
}

-- vim: set ft=lua ts=2 sts=2 sw=2 et:
