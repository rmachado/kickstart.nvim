vim.pack.add { 'https://github.com/folke/snacks.nvim' }

require('snacks').setup {
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
      -- The default `startup` section requires lazy.nvim (for `lazy.stats`),
      -- which kickstart no longer uses. Disable it to avoid the error.
      { section = 'startup', enabled = false },
    },
  },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  picker = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
}
