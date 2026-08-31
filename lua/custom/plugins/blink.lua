-- Override blink.cmp keymaps to prefer Enter-to-confirm and Tab-to-cycle
-- (upstream uses the `default` preset, where Tab moves through snippets and
-- `<C-y>` accepts). blink.cmp reads its config asynchronously after init.lua
-- finishes, so merging here takes effect without re-running setup.
local blink_cmp = require 'blink.cmp.config'
blink_cmp.merge_with {
  keymap = {
    preset = 'enter',
    ['<Tab>'] = { 'select_next' },
    ['<S-Tab>'] = { 'select_prev' },
  },
}
