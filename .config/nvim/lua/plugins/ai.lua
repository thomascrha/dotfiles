return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      -- Cache frequently used modules
      local copilot = require("copilot")

      -- Create a global table to store buffer-specific auto_trigger states
      _G.copilot_buffer_states = {}

      -- Setup configuration
      copilot.setup({
        auto_refresh = true,
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = false, -- Disable default keymaps
            next = false,
            prev = false,
          },
        },
        filetypes = {
          ["*"] = true, -- Enable for all filetypes
        },
      })

      local suggestion = require("copilot.suggestion")

      -- Set up autocmd to initialize buffer state when a new buffer is opened
      vim.api.nvim_create_autocmd({ "BufEnter", "BufNew" }, {
        callback = function(ev)
          local bufnr = ev.buf
          -- Initialize buffer state to false (disabled) if not already set
          if _G.copilot_buffer_states[bufnr] == nil then
            _G.copilot_buffer_states[bufnr] = true
          end
        end,
        desc = "Initialize copilot buffer state",
      })

      -- Clean up buffer state when buffer is deleted
      vim.api.nvim_create_autocmd("BufDelete", {
        callback = function(ev)
          local bufnr = ev.buf
          _G.copilot_buffer_states[bufnr] = nil
        end,
        desc = "Clean up copilot buffer state",
      })

      -- Define keymaps in a table for better organization
      vim.keymap.set("i", "<C-u>", function()
        suggestion.accept()
      end, { desc = "Accept copilot suggestion" })

      vim.keymap.set("i", "<C-.>", function()
        suggestion.next()
      end, { desc = "Next copilot suggestion" })

      vim.keymap.set("i", "<C-,>", function()
        suggestion.prev()
      end, { desc = "Previous copilot suggestion" })

      -- toggle auto trigger with status message
      vim.keymap.set("n", "<leader>ct", function()
        local bufnr = vim.api.nvim_get_current_buf()
        suggestion.toggle_auto_trigger()
        -- Update the buffer state to the opposite of what it was
        _G.copilot_buffer_states[bufnr] = not _G.copilot_buffer_states[bufnr]
        -- Display current buffer's auto-trigger status
        vim.notify(
          "Copilot auto-trigger "
          .. (_G.copilot_buffer_states[bufnr] and "enabled" or "disabled")
          .. " for current buffer",
          vim.log.levels.INFO
        )
      end, { desc = "[C]opilot [t]oggle auto trigger" })
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = "v0.0.27",
    keys = {
      { "<leader>aC", "<cmd>AvanteClear<cr>", desc = "Avante: Clear Avante" },
      {
        "<leader>am",
        function()
          -- Find the Avante window by filetype
          local avante_win = nil
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if string.match(vim.bo[buf].filetype, "Avante") then
              avante_win = win
              break
            end
          end

          if avante_win then
            local current_width = vim.api.nvim_win_get_width(avante_win)
            -- The width from opts is a percentage.
            local default_width_percentage = 40
            local default_width = math.floor(vim.o.columns * default_width_percentage / 100)

            -- Toggle between default and maximized width.
            -- Using a small tolerance for comparison due to potential rounding.
            if math.abs(current_width - default_width) <= 1 then
              -- Maximize width
              vim.api.nvim_win_set_width(avante_win, vim.o.columns)
            else
              -- Restore to default width
              vim.api.nvim_win_set_width(avante_win, default_width)
            end
          else
            vim.notify("Avante window not found", vim.log.levels.WARN)
          end
        end,
        desc = "Avante: [m]aximize/restore window width",
      },
    },
    opts = {
      provider = "copilot",
      mode = "legacy",
      debug = false,
      providers = {
        copilot = {
          -- model = "claude-3.7-sonnet-thought",
          model = "gemini-2.5-pro",
          disable_tools = true,
          extra_request_body = {
            max_tokens = 65536,
          },
        },
      },
      hints = { enabled = false },
      behaviour = {
        auto_focus_sidebar = false, -- Set to false to prevent auto-focus and entering insert mode
        auto_suggestions = false,
        auto_suggestions_respect_ignore = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        minimize_diff = true,
        enable_token_counting = true,
        enable_cursor_planning_mode = true,
        use_cwd_as_project_root = false,
        auto_focus_on_diff_view = false,
        auto_approve_tool_permissions = true,
      },
      windows = {
        width = 40,
        input = {
          height = 20, -- Increase the height of the input window
        },
        ask = {
          start_insert = false, -- Do not start in insert mode for ask window
        },
      },
    },
    config = function(_, opts)
      require("avante").setup(opts)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "Avante*",
        callback = function(args)
          vim.keymap.set("n", "q", "<cmd>AvanteToggle<cr>", {
            buffer = args.buf,
            silent = true,
            desc = "Close Avante window",
          })
        end,
        desc = "Set buffer-local keymap for Avante window",
      })
    end,
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "stevearc/dressing.nvim", -- for input provider dressing
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
