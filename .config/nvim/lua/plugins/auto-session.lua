return {
  -- {
  --   'rmagatti/auto-session',
  --   lazy = false,
  --   ---enables autocomplete for opts
  --   ---@module "auto-session"
  --   ---@type AutoSession.Config
  --   opts = {
  --     suppressed_dirs = { '~/', '~/Downloads', '/' },
  --     -- log_level = 'debug',
  --   }
  -- }
  {
    'tpope/vim-obsession',
    -- Optional: lazy load only when needed
    cmd = "Obsession",
  }
}
-- vim: set ft=lua ts=2 sts=2 sw=2 et:
