return {
  setup = function()
    local function augroup(name)
      return vim.api.nvim_create_augroup( name, { clear = true })
    end
    -- Check if we need to reload the file when it changed
    vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
      group = augroup("checktime"),
      command = "checktime",
    })

    -- Highlight on yank
    vim.api.nvim_create_autocmd("TextYankPost", {
      group = augroup("highlight_yank"),
      callback = function()
        vim.highlight.on_yank()
      end,
    })

    -- resize splits if window got resized
    vim.api.nvim_create_autocmd({ "VimResized" }, {
      group = augroup("resize_splits"),
      callback = function()
        vim.cmd("tabdo wincmd =")
      end,
    })

    -- go to last loc when opening a buffer
    vim.api.nvim_create_autocmd("BufReadPost", {
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
    })

    -- close some filetypes with <q>
    vim.api.nvim_create_autocmd("FileType", {
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
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
      end,
    })

    -- wrap and check for spell in text filetypes
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup("wrap_spell"),
      pattern = { "gitcommit", "markdown", "text", "tex", "org", "mail" },
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
      end,
    })


    -- start telescope find files if no args or first arg is a directory
    -- vim.api.nvim_create_autocmd("VimEnter", {
    --   callback = function()
    --     local first_arg = vim.fn.argv(0)
    --
    --     -- if first arg is a directory, cd into it
    --     if vim.fn.isdirectory(first_arg) ~= 0 then
    --       vim.fn.execute("cd " .. first_arg)
    --     end
    --
    --     if first_arg == "" or vim.fn.isdirectory(first_arg) then
    --       require("telescope.builtin").find_files()
    --     end
    --   end,
    -- })


    -- -- Automatically open preview in oil.nvim
    -- vim.api.nvim_create_autocmd("User", {
    --   pattern = "OilEnter",
    --   callback = vim.schedule_wrap(function(args)
    --     local oil = require("oil")
    --     if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
    --       oil.open_preview()
    --     end
    --   end),
    -- })

    -- Auto select virtualenv Nvim open
    vim.api.nvim_create_autocmd('VimEnter', {
      desc = 'Auto select virtualenv Nvim open',
      -- pattern = '*',
      callback = function()
        local venv = vim.fn.findfile('pyproject.toml', vim.fn.getcwd() .. ';')
        local venvFolder = vim.fn.finddir('.venv', vim.fn.getcwd() .. ';')
        if venv ~= '' or venvFolder ~= '' then
          require('venv-selector').retrieve_from_cache()
        end
      end,
      once = true,
    })

  end
}
