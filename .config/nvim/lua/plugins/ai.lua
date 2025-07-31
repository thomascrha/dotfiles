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
          auto_trigger = false,
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
            _G.copilot_buffer_states[bufnr] = false
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

      vim.keymap.set("n", "<leader>ce", function()
        vim.cmd("Copilot enable")
        vim.cmd("Copilot status")
      end, { desc = "[C]opilot [e]nable" })

      vim.keymap.set("n", "<leader>cd", function()
        vim.cmd("Copilot disable")
        vim.cmd("Copilot status")
      end, { desc = "[C]opilot [d]isable" })

      vim.keymap.set("n", "<leader>cs", function()
        vim.cmd("Copilot status")
      end, { desc = "[C]opilot [s]tatus" })

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

      -- show current buffer's auto-trigger status
      vim.keymap.set("n", "<leader>cc", function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.notify(
          "Copilot auto-trigger "
            .. (_G.copilot_buffer_states[bufnr] and "enabled" or "disabled")
            .. " for current buffer",
          vim.log.levels.INFO
        )
      end, { desc = "[C]opilot [c]urrent auto trigger status" })
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = "v0.0.27",
    keys = {
      { "<leader>aC", "<cmd>AvanteClear<cr>", desc = "Avante: Clear Avante" },
    },
    opts = {
      provider = "copilot",
      mode = "legacy",
      debug = false,
      providers = {
        copilot = {
          model = "claude-3.7-sonnet-thought",
          -- model = "gemini-2.5-pro",
          disable_tools = true,
          extra_request_body = {
            max_tokens = 65536,
          },
        },
      },
      selector = {
        provider = "snacks",
        provider_opts = {
          hidden = true
        },
        exclude_auto_select = {}, -- List of items to exclude from auto selection
      },
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
-- vaim: set ft=lua ts=2 sts=2 sw=2 et:
