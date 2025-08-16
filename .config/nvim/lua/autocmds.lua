return {
  setup = function()
    local function augroup(name)
      return vim.api.nvim_create_augroup(name, { clear = true })
    end

    local create_autocmd = vim.api.nvim_create_autocmd
    local set_keymap = vim.keymap.set
    local opt_local = vim.opt_local

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
        ---@param client vim.lsp.Client
        ---@param method vim.lsp.protocol.Method
        ---@param bufnr? integer some lsp support methods only in specific files
        ---@return boolean
        local function client_supports_method(client, method, bufnr)
          if vim.fn.has("nvim-0.11") == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if
          client
          and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
        then
          local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = "highlight", buffer = event2.buf })
            end,
          })
        end
      end,
    })

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
  end,
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
