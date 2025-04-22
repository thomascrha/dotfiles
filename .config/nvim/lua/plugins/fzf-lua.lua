-- Fuzzy Finder using fzf-lua (alternative to telescope)
return {
  {
    "ibhagwan/fzf-lua",
    event = "VimEnter",
    opts = {
      -- Global settings
      global_resume = true,
      global_resume_query = true,
      winopts = {
        height = 0.85,
        width = 0.80,
        preview = {
          hidden = "nohidden",
          vertical = "down:45%",
          layout = "flex",
        },
      },
      keymap = {
        builtin = {
          ["<C-/>"] = "toggle-help",
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
      },
      fzf_opts = {
        -- Options passed directly to fzf
        ["--layout"] = "reverse",
      },
      -- Customize find command
      files = {
        cmd = "rg --files --hidden -g '!node_modules/**' -g '!.git/**' -g '!dist/**' -g '!build/**'",
      },
      grep = {
        rg_opts = "--hidden --column --line-number --no-heading " ..
          "--color=always --smart-case " ..
          "-g '!node_modules/**' -g '!.git/**' -g '!dist/**' -g '!build/**'",
      },
    },
    keys = {
      -- Basic file and buffer operations
      { "<leader>ff", function() require("fzf-lua").files() end, desc = "[S]earch [F]iles" },
      { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "[S]earch by [G]rep" },
      { "<leader><leader>", function() require("fzf-lua").buffers() end, desc = "[ ] Find existing buffers" },
      { "<leader>/", function() require("fzf-lua").lgrep_curbuf() end, desc = "[/] Fuzzily search in current buffer" },

      -- Additional functionalities
      { "<leader>fh", function() require("fzf-lua").help_tags() end, desc = "[S]earch [H]elp" },
      { "<leader>fk", function() require("fzf-lua").keymaps() end, desc = "[S]earch [K]eymaps" },
      { "<leader>fs", function() require("fzf-lua").builtin() end, desc = "[S]earch [S]elect FZF" },
      { "<leader>fw", function() require("fzf-lua").grep_cword() end, desc = "[S]earch current [W]ord" },
      { "<leader>fd", function() require("fzf-lua").diagnostics_document() end, desc = "[S]earch [D]iagnostics" },
      { "<leader>fr", function() require("fzf-lua").resume() end, desc = "[S]earch [R]esume" },
      { "<leader>f.", function() require("fzf-lua").oldfiles() end, desc = '[S]earch Recent Files ("." for repeat)' },

      -- Advanced searches
      { "<leader>f/", function()
        require("fzf-lua").live_grep({ grep_open_files = true, prompt = "Live Grep in Open Files> " })
      end, desc = "[S]earch [/] in Open Files" },

      -- Config files
      { "<leader>fn", function()
        require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
      end, desc = "[S]earch [N]eovim files" },
    },
  },
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:

