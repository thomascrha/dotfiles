return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-plenary",
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-vim-test",
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python")({
          dap = { justMyCode = false },
        }),
        require("neotest-plenary"),
        require("neotest-vim-test")({
          ignore_file_types = { "python", "vim", "lua" },
        }),

      },
    })
    vim.keymap.set("n", "<leader>tt", [[ <Esc><Cmd>lua require("neotest").run.run()<CR>]], { desc = 'Run nearest [T]est'})
    vim.keymap.set("n", "<leader>ts", [[ <Esc><Cmd>lua require("neotest").run.stop()<CR>]], { desc = '[T]est  [S]top'})
    vim.keymap.set("n", "<leader>ta", [[ <Esc><Cmd>lua require("neotest").run.attach()<CR>]], { desc = '[T]est  [A]ttach'})
    vim.keymap.set("n", "<leader>tf", [[ <Esc><Cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>]], { desc = 'Run [T]ests in [F]ile'})
    vim.keymap.set("n", "<leader>td", [[ <Esc><Cmd>lua require("neotest").run.run({strategy = "dap"})<CR>]], { desc = 'Run [T]ests [D]ebug'})
-- require("neotest").run.run({strategy = "dap"})
  end,
}
