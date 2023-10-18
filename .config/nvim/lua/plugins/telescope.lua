return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")
      require("telescope").load_extension("neoclip")
      require("telescope").load_extension('harpoon')

      -- set up addtional args for rg when finding/grepping files
      local additional_args = function(opts)
        return
      end
      require("telescope").setup {
        defaults = {
          mappings = {
            n = {
              ["|"] = require("telescope.actions").select_vertical,
              ["_"] = require("telescope.actions").select_horizontal,
            },
          },
        },
        pickers = {
          live_grep = {
            additional_args = {"--hidden", '-g', '!node_modules/**', '-g', '!.git/**', '-g', '!dist/**', '-g', '!build/**'},
          },
          find_files = {
            find_command = {'rg', '--files', "--hidden", '-g', '!node_modules/**', '-g', '!.git/**', '-g', '!dist/**', '-g', '!build/**'},
          },
        },
      }

      -- keymaps
      local telescope = require('telescope.builtin')
      vim.keymap.set('n', '<leader>?', telescope.oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        telescope.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer]' })
      vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = '[F]ind [F]iles' })
      vim.keymap.set('n', '<leader>fh', telescope.help_tags, { desc = '[F]ind [H]elp' })
      vim.keymap.set('n', '<leader>fw', telescope.grep_string, { desc = '[F]ind current [W]ord' })
      vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = '[F]ind by [G]rep' })
      vim.keymap.set('n', '<leader>fd', telescope.diagnostics, { desc = '[F]ind [D]iagnostics' })

      vim.keymap.set('n', '<leader>fb', ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = '[F]ile [B]rowser' })
      vim.keymap.set('n', '<leader>fc', ":Telescope neoclip<CR>", { desc = '[F]ind [C]lips (Register)' })

      vim.keymap.set('n', '<leader>cc', telescope.colorscheme, { desc = '[C]olour [S]cheme select' })

    end
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = vim.fn.executable("make") == 1,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function ()
      require("telescope").setup {
        extensions = {
          file_browser = {
            intial_mode = "normal",
            -- makes window appear from the bottom
            theme = "ivy",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            hidden = { file_browser = true, folder_browser = true },
          },
        }
      }

    end
  },
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {"kkharji/sqlite.lua"},
    config = function()
      require('neoclip').setup()
    end,
  },
}
