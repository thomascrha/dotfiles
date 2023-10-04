return {
  setup = function()
    -- Make line numbers default
    vim.wo.number = true

    -- set mouse mode (all modes)
    vim.o.mouse = "a"

    -- Search
    -- ignorecase during search
    vim.o.ignorecase = true
    -- if search has capital match case
    vim.o.smartcase = true
    -- don"t highlight search
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

    -- colun width
    vim.o.colorcolumn = "120"

    -- Decrease update time
    vim.o.updatetime = 200
    vim.wo.signcolumn = 'yes'

    -- Set completeopt to have a better completion experience
    vim.o.completeopt = 'menuone,noselect'

    -- Save undo history
    vim.o.undofile = true
    vim.o.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"

    -- scrolling padding
    vim.o.scrolloff = 8

    --  spelling
    -- vim.o.spell = true
    vim.o.spelllang = 'en_au,programming'
    vim.o.spelloptions = "camel"

    -- enable current line highlighting
    vim.o.cursorline = true

    -- make splits open to down and right
    vim.o.splitbelow = true
    vim.o.splitright = true

    vim.g.copilot_assume_mapped = true

    -- disable built-in plugins
    -- local disabled_built_ins = {
    -- 	"2html_plugin",
    -- 	"getscript",
    -- 	"getscriptPlugin",
    -- 	"gzip",
    -- 	"logipat",
    -- 	"netrw",
    -- 	"netrwPlugin",
    -- 	"netrwSettings",
    -- 	"netrwFileHandlers",
    -- 	"matchit",
    -- 	"tar",
    -- 	"tarPlugin",
    -- 	"rrhelper",
    -- 	"spellfile_plugin",
    -- 	"vimball",
    -- 	"vimballPlugin",
    -- 	"zip",
    -- 	"zipPlugin",
    -- }
    --
    -- for _, plugin in pairs(disabled_built_ins) do
    -- 	vim.g["loaded_" .. plugin] = 1
    -- end
    --
    -- Nice looking file diff
    vim.o.fillchars = 'diff:/'

    -- setup clipbard WSL
    -- if vim.fn.has("wsl") then
    --     vim.g.clipboard = {
    --         name = "clip.exe (Copy Only)",
    --         copy = {
    --             ["+"] = "clip.exe",
    --             ["*"] = "clip.exe"
    --         },
    --         cache_enabled = true
    --     }
    -- end
  end
}
