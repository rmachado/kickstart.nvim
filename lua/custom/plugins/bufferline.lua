vim.pack.add { { src = 'https://github.com/akinsho/bufferline.nvim', version = vim.version.range '*' } }

require('bufferline').setup {
  options = {
    mode = 'tabs',
  },
}
