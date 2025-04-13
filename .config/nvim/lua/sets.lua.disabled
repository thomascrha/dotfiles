return {
  setup = function()
    -----------------
    -- Basic Settings
    -----------------

    -- Leader Key
    -- `:help mapleader` - Defines the key used as the "leader" for key mapping
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    -- Nerd Font Support
    -- `:help nerd-font` - For plugins that use special glyphs from nerd fonts
    vim.g.have_nerd_font = false

    -----------------
    -- Display Settings
    -----------------

    -- Line Numbers
    -- `:help relativenumber` - Show the line number relative to the cursor
    vim.opt.relativenumber = true

    -- `:help cursorline` - Highlight the line where the cursor is
    vim.opt.cursorline = true

    -- `:help cmdheight` - Height of the command line
    vim.opt.cmdheight = 1

    -- `:help colorcolumn` - Highlight the specified column
    vim.opt.colorcolumn = "120"

    -- `:help termguicolors` - Use GUI colors in terminal
    vim.opt.termguicolors = true

    -- `:help showmode` - Shows the current mode in the status line
    vim.opt.showmode = false

    -- `:help fillchars` - Characters to fill statusline/statuscolumn
    vim.opt.fillchars = "diff:/"

    -----------------
    -- Mouse & Input
    -----------------

    -- `:help mouse` - Enables mouse support for all modes
    vim.opt.mouse = "a"

    -- `:help mousemodel` - Behavior of mouse clicks
    vim.opt.mousemodel = "extend"

    -- `:help timeoutlen` - Time in ms to wait for a mapped sequence to complete
    vim.opt.timeoutlen = 300

    -- `:help errorbells` - Disable error bells/beeps
    vim.opt.errorbells = false

    -----------------
    -- Clipboard
    -----------------

    -- `:help clipboard` - Sync with system clipboard
    -- Sync clipboard between OS and Neovim.
    -- Schedule the setting after `UiEnter` because it can increase startup-time.
    -- Remove this option if you want your OS clipboard to remain independent.
    vim.schedule(function()
      vim.opt.clipboard = "unnamedplus"
    end)

    -----------------
    -- Search Settings
    -----------------

    -- `:help ignorecase` - Ignore case in search patterns
    vim.opt.ignorecase = true

    -- `:help smartcase` - Override ignorecase if search contains uppercase
    vim.opt.smartcase = true

    -- `:help hlsearch` - Don't highlight all matches for search pattern
    vim.opt.hlsearch = false

    -- `:help incsearch` - Show matches as you type the search pattern
    vim.opt.incsearch = true

    -- `:help inccommand` - Preview substitutions as you type
    vim.opt.inccommand = "split"

    -----------------
    -- Editor Behavior
    -----------------

    -- `:help wrap` - Lines longer than the window width wrap
    vim.opt.wrap = true

    -- `:help breakindent` - Wrapped lines will maintain their indentation
    vim.opt.breakindent = true

    -- `:help scrolloff` - Minimum lines to keep above/below cursor when scrolling
    vim.opt.scrolloff = 10

    -- `:help list` - Show invisible characters
    -- `:help listchars` - Configure which invisible characters to show
    vim.opt.list = true
    vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

    -- `:help signcolumn` - Column for displaying signs (like diagnostics)
    vim.opt.signcolumn = "yes"

    -- `:help updatetime` - Time in ms before various operations trigger
    vim.opt.updatetime = 250

    -- `:help completeopt` - Options for insert mode completion
    vim.opt.completeopt = "menuone,noselect"

    -- `:help confirm` - Ask for confirmation instead of failing
    vim.opt.confirm = true

    -----------------
    -- Split Windows
    -----------------

    -- `:help splitright` and `:help splitbelow` - Where new splits appear
    vim.opt.splitright = true
    vim.opt.splitbelow = true

    -----------------
    -- Tab & Indentation
    -----------------

    -- `:help tabstop` - Number of spaces a <Tab> counts for
    vim.opt.tabstop = 4

    -- `:help shiftwidth` - Number of spaces to use for auto-indent
    vim.opt.shiftwidth = 4

    -- `:help softtabstop` - Number of spaces a <Tab> counts for in editing operations
    vim.opt.softtabstop = 4

    -- `:help expandtab` - Convert tabs to spaces
    vim.opt.expandtab = true

    -- `:help smartindent` - Smart auto-indenting for programs
    vim.opt.smartindent = true

    -----------------
    -- File Handling
    -----------------

    -- `:help undofile` - Save undo history between sessions
    vim.opt.undofile = true

    -- `:help undodir` - Directory for storing undo files
    vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"

    -- `:help swapfile` and `:help backup` - Disable swap and backup files
    vim.opt.swapfile = false
    vim.opt.backup = false

    -----------------
    -- Spelling
    -----------------

    -- `:help spell` - Enable spell checking
    -- vim.opt.spell = true

    -- `:help spelllang` - Language(s) for spell checking
    vim.opt.spelllang = "en_au,programming"

    -- `:help spelloptions` - Options for spell checking
    vim.opt.spelloptions = "camel"

    -----------------
    -- Plugin Settings
    -----------------

    -- GitHub Copilot setting to override mappings
    vim.g.copilot_assume_mapped = true
  end,
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
