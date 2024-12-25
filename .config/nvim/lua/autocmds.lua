return {
  setup = function()
    local function augroup(name)
      return vim.api.nvim_create_augroup(name, { clear = true })
    end

    local create_autocmd = vim.api.nvim_create_autocmd
    local set_keymap = vim.keymap.set
    local opt_local = vim.opt_local

    -- Check if we need to reload the file when it changed
    create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
      group = augroup("checktime"),
      command = "checktime",
      desc = "Reload the file when it changes",
    })

    -- Highlight on yank
    create_autocmd("TextYankPost", {
      group = augroup("highlight_yank"),
      callback = function()
        vim.highlight.on_yank()
      end,
      desc = "Highlight text on yank",
    })

    -- Resize splits if window got resized
    create_autocmd("VimResized", {
      group = augroup("resize_splits"),
      callback = function()
        vim.cmd("tabdo wincmd =")
      end,
      desc = "Resize splits when the window is resized",
    })

    -- Go to last location when opening a buffer
    create_autocmd("BufReadPost", {
      group = augroup("last_loc"),
      callback = function()
        local exclude = { "gitcommit" }
        local buf = vim.api.nvim_get_current_buf()
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
          return
        end
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
          pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
      end,
      desc = "Go to last location when opening a buffer",
    })

    -- Close some filetypes with <q>
    create_autocmd("FileType", {
      group = augroup("close_with_q"),
      pattern = {
        "help",
        "lspinfo",
        "man",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "neotest-output",
        "checkhealth",
        "neotest-summary",
        "neotest-output-panel",
      },
      callback = function(event)
        vim.bo[event.buf].buflisted = false
        set_keymap("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
      end,
      desc = "Close certain filetypes with <q>",
    })

    -- Wrap and check for spell in text filetypes
    create_autocmd("FileType", {
      group = augroup("wrap_spell"),
      pattern = { "gitcommit", "markdown", "text", "tex", "org", "mail" },
      callback = function()
        opt_local.wrap = true
        opt_local.spell = true
      end,
      desc = "Enable wrap and spell check for text filetypes",
    })

    -- Auto select virtualenv on Nvim open
    -- create_autocmd('VimEnter', {
    --   desc = 'Auto select virtualenv on Nvim open',
    --   pattern = '*',
    --   callback = function()
    --     local venv = vim.fn.findfile('pyproject.toml', vim.fn.getcwd() .. ';')
    --     local venvFolder = vim.fn.finddir('.venv', vim.fn.getcwd() .. ';')
    --     if venv ~= '' or venvFolder ~= '' then
    --       require('venv-selector').venv()
    --     end
    --   end,
    --   once = true,
    -- })

    create_autocmd('ModeChanged', {callback = function()
      require('lualine').refresh {scope = 'window',  place = {'statusline'}}
    end})

    -- Disable line numbers in oil buffers
    create_autocmd("BufEnter", {
      group = augroup("oil_settings"),
      pattern = "oil://*",
      callback = function()
        opt_local.number = false
        opt_local.relativenumber = false
      end,
      desc = "Disable line numbers in oil file explorer",
    })
  end
}
