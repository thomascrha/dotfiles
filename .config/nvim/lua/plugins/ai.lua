return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      -- Cache frequently used modules
      local copilot = require("copilot")

      -- require("copilot").setup({
      --   suggestion = { enabled = false },
      --   panel = { enabled = false },
      -- })
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
          ["*"] = true,
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
      })

      -- Clean up buffer state when buffer is deleted
      vim.api.nvim_create_autocmd("BufDelete", {
        callback = function(ev)
          local bufnr = ev.buf
          _G.copilot_buffer_states[bufnr] = nil
        end,
      })

      -- Define keymaps in a table for better organization
      vim.keymap.set("i", "<C-u>", function()
        suggestion.accept()
      end, {})
      vim.keymap.set("i", "<C-.>", function()
        suggestion.next()
      end, {})
      vim.keymap.set("i", "<C-,>", function()
        suggestion.prev()
      end, {})
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
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = function()
      -- Only build tiktoken on Unix systems
      if vim.fn.has("unix") == 1 then
        vim.fn.system("make tiktoken")
      end
    end,
    opts = {
      -- Add some default configuration
      model = "claude-3.7-sonnet-thought",
      debug = false, -- Enable debugging
      show_help = true, -- Show help message in command line
      prompts = {
        -- Add custom prompts
        Explain = "Explain how this code works:",
        Review = "Review this code and suggest improvements:",
        Tests = "Generate unit tests for this code:",
      },
    },
  },
  -- {
  --   "olimorris/codecompanion.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   config = function()
  --     require("codecompanion").setup({
  --       strategies = {
  --         chat = {
  --           adapter = "copilot",
  --         },
  --         inline = {
  --           adapter = "copilot",
  --         },
  --       },
  --       adapters = {
  --         openai = function()
  --           return require("codecompanion.adapters").extend("copilot", {
  --             schema = {
  --               model = {
  --                 default = "claude-3.7-sonnet",
  --               },
  --             },
  --           })
  --         end,
  --       },
  --     })
  --   end,
  -- },
  {
    "yetone/avante.nvim",
    -- dir = "/home/tcrha/Projects/avante.nvim",
    event = "VeryLazy",
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      debug = false,
      -- add any opts here
      -- for example
      provider = "copilot",
      copilot = {
        -- model = "o1",
        -- model = "gemini-2.0-flash-001",
        model = "claude-3.7-sonnet",
        -- model = "claude-3.7-sonnet-thought",
        disable_tools = true,
        -- max_tokens = 4096,
      },
      file_selector = {
      --   -- show_hidden = true
        provider = "fzf",
      --   provider_opts = {
      --     find_command = { "rg", "--files", "--hidden", "-g", "!.git" }
      --   }
      },
      vendors = {
        copilot_claude = {
          __inherited_from = "copilot",
          model = "claude-3.7-sonnet",
        },
        copilot_claude_thinking = {
          __inherited_from = "copilot",
          model = "claude-3.7-sonnet-thought",
        },
        copilot_o1 = {
          __inherited_from = "copilot",
          model = "o1",
        },
        copilot_o3_mini = {
          __inherited_from = "copilot",
          model = "o3-mini",
        },
        copilot_gemini = {
          __inherited_from = "copilot",
          model = "gemini-2.0-flash-100",
        },
        copilot_4openai = {
          __inherited_from = "copilot",
          model = "gpt-4o-2024-08-06",
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- {
      --   -- Make sure to set this up properly if you have lazy=true
      --   "MeanderingProgrammer/render-markdown.nvim",
      --   opts = {
      --     file_types = { "markdown", "Avante" },
      --   },
      --   ft = { "markdown", "Avante" },
      -- },
    },
  },
  -- {
  --   "yetone/avante.nvim",
  --   event = "VeryLazy",
  --   lazy = false,
  --   version = false,
  --   opts = {
  --     provider = "copilot",
  --     web_search_engine = {
  --       provider = "tavily", -- tavily, serpapi, searchapi, google or kagi
  --       -- You need to set the environment variable TAVILY_API_KEY
  --     },
  --
  --     copilot = {
  --       model = "claude-3.7-sonnet", -- Updated model name
  --       -- max_tokens = 4096,
  --     },
  --     -- Add UI configuration
  --     ui = {
  --       border = "rounded",
  --       width = 0.8, -- 80% of screen width
  --       height = 0.8, -- 80% of screen height
  --       transparency = 0, -- Fully opaque
  --     },
  --     -- Add keymaps configuration
  --     keymaps = {
  --       close = "<Esc>",
  --       submit = "<C-Enter>",
  --       toggle = "<leader>aa",
  --     },
  --   },
  --   build = vim.fn.has('win32') == 1
  --     and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
  --     or "make",
  --   dependencies = {
  --     "stevearc/dressing.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --     "hrsh7th/nvim-cmp",
  --     "nvim-tree/nvim-web-devicons",
  --     "zbirenbaum/copilot.lua",
  --     {
  --       "HakonHarnes/img-clip.nvim",
  --       event = "VeryLazy",
  --       opts = {
  --         default = {
  --           embed_image_as_base64 = false,
  --           prompt_for_file_name = false,
  --           drag_and_drop = {
  --             insert_mode = true,
  --           },
  --           use_absolute_path = vim.fn.has('win32') == 1,
  --           -- Add image directory configuration
  --           image_dir = "assets/images",
  --           -- Add file naming pattern
  --           file_name_pattern = "%Y%m%d_%H%M%S",
  --         },
  --       },
  --     },
  --     {
  --       'MeanderingProgrammer/render-markdown.nvim',
  --       opts = {
  --         file_types = { "markdown", "Avante" },
  --         -- Add highlighters configuration
  --         highlighters = {
  --           code_blocks = true,
  --           headlines = true,
  --           tables = true,
  --         },
  --       },
  --       ft = { "markdown", "Avante" },
  --     },
  --   },
  -- }
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
