return {
  {
    'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      local copilot = require('copilot')
      local suggestion = require('copilot.suggestion')

      copilot.setup({
        auto_refresh = true,
        -- model = "claude-3-5-sonnet",
        suggestion = {
          auto_trigger = true

        },
        filetypes = {
          ["*"] = true
        }
      })

      vim.keymap.set('i', '<C-u>', function() suggestion.accept() end, {})
      vim.keymap.set('i', '<C-n>', function() suggestion.next() end, {})
      vim.keymap.set('i', '<C-p>', function() suggestion.previous() end, {})

      -----------------------------------------------------------------------------------
      --
      -- " Copilot
      -----------------------------------------------------------------------------------
      vim.keymap.set('n', '<leader>ce', '<cmd>Copilot enable<cr><cmd>Copilot status<cr>', { desc = '[C]opilot [e]nable'})
      vim.keymap.set('n', '<leader>cd', '<cmd>Copilot disable<cr><cmd>Copilot status<cr>', { desc = '[C]opilot [d]isable' })
      vim.keymap.set('n', '<leader>cs', '<cmd>Copilot status<cr>', { desc = '[C]opilot [s]tatus' })
    end
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "copilot",
      copilot = {
        model = "claude-3.5-sonnet",
        -- max_tokens = 4096,
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
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
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  }
}
