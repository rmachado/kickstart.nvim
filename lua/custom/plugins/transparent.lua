vim.pack.add { 'https://github.com/xiyaowong/transparent.nvim' }

local transparent = require 'transparent'

vim.g.transparent_enabled = true

transparent.clear_prefix 'BufferLine'
transparent.clear_prefix 'NeoTree'
transparent.clear_prefix 'lualine'
