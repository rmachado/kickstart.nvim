return {
  'xiyaowong/transparent.nvim',
  priority = 1000,
  lazy = false,
  config = function()
    local transparent = require 'transparent'

    transparent.clear_prefix 'BufferLine'
    transparent.clear_prefix 'NeoTree'
    transparent.clear_prefix 'lualine'

    vim.g.transparent_enabled = true
  end,
}
