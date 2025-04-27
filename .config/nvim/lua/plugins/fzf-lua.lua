return {
  {
    "ibhagwan/fzf-lua",
    event = "VimEnter",
    dependencies = {
      -- Useful for getting pretty icons, but requires a Nerd Font.
      -- { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- fzf-lua is a fast fuzzy finder that leverages the power of fzf
      -- It can search many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- To learn more about fzf-lua, see: https://github.com/ibhagwan/fzf-lua

      -- [[ Configure fzf-lua ]]
      local fzf = require("fzf-lua")

      fzf.setup({
        -- Global fzf-lua settings
        global_resume = true,
        global_resume_query = true,
        winopts = {
          height = 0.85,
          width = 0.80,
          preview = {
            scrollbar = "float",
          },
        },
        keymap = {
          -- These keys work in fzf's popup window
          builtin = {
            ["<c-/>"] = "toggle-help",
            ["<c-q>"] = "toggle-fullscreen",
            ["<c-r>"] = "toggle-preview-wrap",
            ["<c-p>"] = "toggle-preview",
            ["<c-y>"] = "preview-page-up",
            ["<c-e>"] = "preview-page-down",
          },
        },
        fzf_opts = {
          -- Pass additional options to fzf
          ["--layout"] = "reverse",
        },
        grep = {
          rg_opts = "--hidden --column --line-number --no-heading "
            .. "--color=always --smart-case "
            .. "-g '!node_modules/**' -g '!.git/**' -g '!dist/**' -g '!build/**'",
        },
        files = {
          cmd = "rg --files --hidden " .. "-g '!node_modules/**' -g '!.git/**' -g '!dist/**' -g '!build/**'",
        },
      })

      -- Set up keymaps similar to Telescope
      vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "[F]ind [H]elp" })
      vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "[F]ind [K]eymaps" })
      vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "[F]ind [F]iles" })
      vim.keymap.set("n", "<leader>fs", fzf.builtin, { desc = "[F]ind [S]elect FZF" })
      vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "[F]ind current [W]ord" })
      vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "[F]ind by [G]rep" })
      vim.keymap.set("n", "<leader>fd", fzf.diagnostics_document, { desc = "[F]ind [D]iagnostics" })
      vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "[F]ind [R]esume" })
      vim.keymap.set("n", "<leader>f.", fzf.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader><leader>", fzf.buffers, { desc = "[ ] Find existing buffers" })

      -- Slightly advanced example of searching in current buffer
      vim.keymap.set("n", "<leader>/", function()
        fzf.blines({
          winopts = {
            height = 0.5,
            width = 0.5,
            preview = { hidden = "hidden" },
          },
        })
      end, { desc = "[/] Fuzzily search in current buffer" })

      -- Search in open files
      vim.keymap.set("n", "<leader>f/", function()
        fzf.grep({
          search = "",
          no_esc = true,
          only_current_file = true,
          prompt = "Grep in Current File> ",
        })
      end, { desc = "[F]ind [/] in Open Files" })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set("n", "<leader>fn", function()
        fzf.files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[F]ind [N]eovim files" })
    end,
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
