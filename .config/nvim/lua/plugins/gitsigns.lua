return {
  "lewis6991/gitsigns.nvim",
  dependencies = {
    { 'akinsho/git-conflict.nvim', version = "*", config = true }
  },
  -- event = "VeryLazy",
  config = function()
    require("gitsigns").setup({
      signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      signs_staged_enable = true,
      signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
      numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
      linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
      word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        follow_files = true,
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
      },
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil,  -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        -- Navigation
        vim.keymap.set("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { buffer = bufnr, desc = "Next git hunk" })

        vim.keymap.set("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { buffer = bufnr, desc = "Previous git hunk" })

        -- Actions
        vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
        vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { buffer = bufnr, desc = "Reset hunk" })

        vim.keymap.set("v", "<leader>hs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { buffer = bufnr, desc = "Stage selected hunk" })

        vim.keymap.set("v", "<leader>hr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { buffer = bufnr, desc = "Reset selected hunk" })

        vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer, { buffer = bufnr, desc = "Stage buffer" })
        vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { buffer = bufnr, desc = "Reset buffer" })
        vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
        vim.keymap.set("n", "<leader>hi", gitsigns.preview_hunk_inline, { buffer = bufnr, desc = "Preview hunk inline" })

        vim.keymap.set("n", "<leader>hb", function()
          gitsigns.blame_line({ full = true })
        end, { buffer = bufnr, desc = "Blame line" })

        vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, { buffer = bufnr, desc = "Diff this" })

        vim.keymap.set("n", "<leader>hD", function()
          gitsigns.diffthis("~")
        end, { buffer = bufnr, desc = "Diff this ~" })

        vim.keymap.set("n", "<leader>hQ", function()
          gitsigns.setqflist("all")
        end, { buffer = bufnr, desc = "Send all hunks to quickfix" })

        vim.keymap.set("n", "<leader>hq", gitsigns.setqflist, { buffer = bufnr, desc = "Send hunks to quickfix" })

        -- Toggles
        vim.keymap.set("n", "<leader>tb", gitsigns.toggle_current_line_blame,
          { buffer = bufnr, desc = "Toggle current line blame" })
        vim.keymap.set("n", "<leader>tw", gitsigns.toggle_word_diff, { buffer = bufnr, desc = "Toggle word diff" })

        -- Text object
        vim.keymap.set({ "o", "x" }, "ih", gitsigns.select_hunk, { buffer = bufnr, desc = "Select hunk" })
      end,
    })
  end,
}
