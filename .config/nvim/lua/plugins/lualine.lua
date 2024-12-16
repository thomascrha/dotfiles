return {
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        theme = 'onehalfdark',
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1,  -- 1 for relative path, 2 for absolute path
              file_status = true,
              newfile_status = true,
              on_click = function()
                local filename = vim.fn.expand('%:.')  -- %:. gives relative path from current working directory
                vim.fn.setreg('"', filename)
                -- add to system clipvoard
                vim.fn.system('echo ' .. filename .. ' | wl-copy -n')
              end,
            }
          }
        }
      })

    end,
  },
}
