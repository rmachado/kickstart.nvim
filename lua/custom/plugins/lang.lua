-- Language support for JavaScript/TypeScript, Python, Go and Rust.
--
-- Two independent layers provide the inline "errors" you see:
--   * LSP servers (syntax, type and semantic diagnostics)
--   * nvim-lint linters (style, unused imports, suspicious code, ...)
--
-- Everything below lives in the custom/ folder on purpose, so it never
-- conflicts with the kickstart defaults in init.lua or lua/kickstart/.

-- mason.nvim installs the `rust-analyzer` server, but it shells out to the Rust
-- toolchain (`cargo`, `cargo clippy`, `rustc`) which lives in ~/.cargo/bin.
-- That directory is not always on Neovim's PATH (notably when Neovim is started
-- from a desktop launcher instead of a login shell), which makes the server fail
-- with "cargo not found". Prepend it when it exists.
local cargo_home = vim.env.CARGO_HOME or vim.fs.joinpath(vim.env.HOME or '', '.cargo')
local cargo_bin = vim.fs.joinpath(cargo_home, 'bin')
if vim.uv.fs_stat(cargo_bin) and not (vim.env.PATH or ''):find(cargo_bin, 1, true) then
  vim.env.PATH = cargo_bin .. ':' .. (vim.env.PATH or '')
end

-- LSP servers. Keys are nvim-lspconfig server names (also understood by
-- mason-tool-installer and mason-lspconfig).
---@type table<string, vim.lsp.Config>
local servers = {
  -- JavaScript / TypeScript
  ts_ls = {},

  -- Python
  pyright = {},

  -- Go
  gopls = {},

  -- Rust (run `cargo clippy` as the checker so clippy lints show up)
  rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        check = { command = 'clippy' },
      },
    },
  },
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

-- Linters (nvim-lint). Merge instead of assigning so the markdown default
-- configured by `kickstart.plugins.lint` is preserved.
local lint = require 'lint'
lint.linters_by_ft = vim.tbl_deep_extend('force', lint.linters_by_ft or {}, {
  javascript = { 'eslint_d' },
  javascriptreact = { 'eslint_d' },
  typescript = { 'eslint_d' },
  typescriptreact = { 'eslint_d' },
  python = { 'ruff' },
  go = { 'golangci_lint' },
})

-- Declare the tools so a fresh install is reproducible instead of relying on
-- whatever was installed by hand through the `:Mason` TUI.
-- Apply with `:MasonToolsInstall` (or restart Neovim).
require('mason-tool-installer').setup {
  ensure_installed = {
    -- LSP servers
    'lua_ls',
    'stylua',
    'ts_ls',
    'pyright',
    'gopls',
    'rust_analyzer',
    -- Linters
    'ruff',
    'eslint_d',
    'golangci-lint',
  },
}
