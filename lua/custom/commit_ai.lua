-- AI-written commit messages, generated with OpenCode straight into the commit buffer.
--
-- While editing a commit message (a `gitcommit` buffer, e.g. opened by `git commit`)
-- press <leader>ai in normal mode. The staged diff is sent to `opencode run` and the
-- generated message replaces the buffer, keeping git's trailing comment block intact.
--
-- Change the model by editing `M.config.model` below, or from anywhere in your config:
--   require('custom.commit_ai').setup { model = 'provider/model#variant' }

local M = {}

M.config = {
  -- Passed to `opencode run --model` as provider/model or provider/model#variant.
  model = 'opencode-go/deepseek-v4.1-flash',
  -- Optional `opencode run --agent`, e.g. a read-only agent if you have one.
  agent = nil,
  -- Buffer-local keymap installed in commit message buffers.
  keymap = '<leader>ai',
  -- Diffs larger than this many bytes are truncated before being sent to the model.
  max_diff_bytes = 200000,
}

local prompt_template = table.concat({
  'Write a git commit message for the staged changes below.',
  '',
  'Rules:',
  '- Start with a short summary line, 50 characters or fewer, in conventional commits format.',
  '- If it helps, add a blank line and a body wrapped at 72 characters explaining what and why.',
  '- Output only the commit message: no code fences, no explanations, no markdown.',
  '',
  'Diff:',
  '%s',
}, '\n')

local function notify(msg, level)
  vim.notify('commit_ai: ' .. msg, level or vim.log.levels.INFO)
end

--- Run a git command synchronously in `cwd`; returns stdout or nil plus an error.
local function git(cwd, args)
  local cmd = { 'git', '-C', cwd }
  vim.list_extend(cmd, args)
  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    return nil, vim.trim(result.stderr or ('git exited with code ' .. result.code))
  end
  return result.stdout or ''
end

--- Return the staged diff for `cwd`, falling back to the last commit's diff.
local function staged_diff(cwd)
  local diff = git(cwd, { 'diff', '--cached', '--no-color' })
  if not diff or vim.trim(diff) == '' then
    diff = git(cwd, { 'diff', 'HEAD', '--no-color' })
  end
  if not diff then
    return nil, 'could not read the git diff'
  end
  if vim.trim(diff) == '' then
    return nil, 'no changes found to describe'
  end
  if #diff > M.config.max_diff_bytes then
    diff = diff:sub(1, M.config.max_diff_bytes) .. '\n... (diff truncated)'
  end
  return diff
end

--- Replace the commit buffer with `message`, preserving git's comment lines below it.
local function write_message(bufnr, message)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    notify('commit buffer is gone', vim.log.levels.WARN)
    return
  end

  local comment = (vim.bo[bufnr].commentstring or ''):match '^(.-)%%s' or '#'
  comment = vim.trim(comment)
  if comment == '' then
    comment = '#'
  end

  local comments = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line:match('^%s*' .. vim.pesc(comment)) then
      comments[#comments + 1] = line
    end
  end

  local lines = vim.split(message, '\n', { plain = true })
  if #comments > 0 then
    lines[#lines + 1] = ''
    vim.list_extend(lines, comments)
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

--- Generate a commit message for `bufnr` and write it into the buffer.
function M.run()
  local bufnr = vim.api.nvim_get_current_buf()

  if vim.fn.executable 'opencode' ~= 1 then
    notify('`opencode` was not found in PATH', vim.log.levels.ERROR)
    return
  end

  local root = vim.fs.root(bufnr, '.git')
  if not root then
    notify('this file is not inside a git repository', vim.log.levels.ERROR)
    return
  end

  local diff, err = staged_diff(root)
  if not diff then
    notify(err, vim.log.levels.ERROR)
    return
  end

  local cmd = { 'opencode', 'run', '--model', M.config.model }
  if M.config.agent and M.config.agent ~= '' then
    vim.list_extend(cmd, { '--agent', M.config.agent })
  end
  cmd[#cmd + 1] = prompt_template:format(diff)

  notify('generating a commit message with ' .. M.config.model .. '...')

  vim.system(cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        notify('opencode failed: ' .. vim.trim(result.stderr or ('exit code ' .. result.code)), vim.log.levels.ERROR)
        return
      end

      local message = vim.trim(result.stdout or '')
      if message == '' then
        notify('opencode returned an empty message', vim.log.levels.ERROR)
        return
      end

      write_message(bufnr, message)
      notify('commit message ready', vim.log.levels.INFO)
    end)
  end)
end

local function install()
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('CommitAi', { clear = true }),
    pattern = 'gitcommit',
    desc = 'Install the AI commit message keymap in commit buffers',
    callback = function(event)
      vim.keymap.set('n', M.config.keymap, M.run, {
        buffer = event.buf,
        desc = 'AI: write commit message (opencode)',
      })
    end,
  })
end

--- Update the configuration (e.g. the model) and (re)install the auto-command.
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  install()
  return M
end

install()

return M
