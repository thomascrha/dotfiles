return {
  setup = function()
    -- Check if we need to reload the file when it changed
    vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
      group = vim.api.nvim_create_augroup("checktime", { clear = true }),
      command = "checktime",
      desc = "Reload the file when it changes",
    })

    -- Highlight on yank
    vim.api.nvim_create_autocmd("TextYankPost", {
      group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
      callback = function()
        vim.highlight.on_yank()
      end,
      desc = "Highlight text on yank",
    })

    -- Resize splits if window got resized
    vim.api.nvim_create_autocmd("VimResized", {
      group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
      callback = function()
        vim.cmd("tabdo wincmd =")
      end,
      desc = "Resize splits when the window is resized",
    })

    -- Close some filetypes with <q>
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
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
      desc = "Close certain filetypes with <q>",
    })

    -- Wrap and check for spell in text filetypes
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("wrap_spell", { clear = true }),
      pattern = { "gitcommit", "markdown", "text", "tex", "org", "mail" },
      callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
      end,
      desc = "Enable wrap and spell check for text filetypes",
    })

  end,
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
