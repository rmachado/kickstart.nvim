-- Re-run mason-lspconfig setup to automatically enable any server installed
-- via `:Mason` (upstream defaults this to `false`). This is safe to call
-- multiple times; mason-lspconfig explicitly supports repeated setup calls.
require('mason-lspconfig').setup { automatic_enable = true }
