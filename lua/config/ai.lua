local M = {}

local active_provider = vim.g.ai_provider or 'claude'

local providers = {
  claude = {
    label = 'Claude Code',
    open = 'ClaudeCodeFocus',
    close = 'ClaudeCodeClose',
    stop = 'ClaudeCodeStop',
    send = 'ClaudeCodeSend',
    add = 'ClaudeCodeAdd',
    tree_add = 'ClaudeCodeTreeAdd',
    diff_accept = 'ClaudeCodeDiffAccept',
    diff_deny = 'ClaudeCodeDiffDeny',
  },
  codex = {
    label = 'Codex',
    open = 'CodexFocus',
    close = 'CodexClose',
    stop = 'CodexStop',
    send = 'CodexSend',
    add = 'CodexAdd',
    tree_add = 'CodexTreeAdd',
    diff_accept = 'CodexDiffAccept',
    diff_deny = 'CodexDiffDeny',
  },
  opencode = {
    label = 'opencode',
    open_fn = function()
      require('opencode').toggle()
    end,
    close_fn = function()
      require('opencode.config').opts.server.stop()
    end,
    send_fn = function()
      require('opencode').ask('@this: ', { submit = true })
    end,
    add_fn = function()
      require('opencode').prompt('@buffer ')
    end,
    tree_add_fn = function()
      require('opencode').prompt('@this ')
    end,
  },
}

local provider_order = { 'claude', 'codex', 'opencode' }

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = 'AI Provider' })
end

local function command_exists(command)
  return vim.fn.exists(':' .. command) == 2
end

local function run(command, bang)
  if not command or not command_exists(command) then
    return false
  end

  local prefix = bang and 'silent! ' or ''
  local ok, err = pcall(vim.cmd, prefix .. command)
  if not ok then
    notify(err, vim.log.levels.ERROR)
  end

  return ok
end

local function run_with_file(command, path)
  if not command or not command_exists(command) then
    return false
  end

  local ok, err = pcall(vim.cmd, command .. ' ' .. vim.fn.fnameescape(path))
  if not ok then
    notify(err, vim.log.levels.ERROR)
  end

  return ok
end

local function run_fn(func)
  if not func then
    return false
  end

  local ok, err = pcall(func)
  if not ok then
    notify(err, vim.log.levels.ERROR)
  end

  return ok
end

local function current_provider()
  return providers[active_provider] or providers.claude
end

local function focus_previous_editor_window()
  local current_win = vim.api.nvim_get_current_win()

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= current_win and vim.api.nvim_win_is_valid(win) then
      local bufnr = vim.api.nvim_win_get_buf(win)
      local buftype = vim.bo[bufnr].buftype
      local filetype = vim.bo[bufnr].filetype
      local win_config = vim.api.nvim_win_get_config(win)

      if
        buftype == ''
        and not (win_config.relative and win_config.relative ~= '')
        and filetype ~= 'neo-tree'
      then
        vim.api.nvim_set_current_win(win)
        return true
      end
    end
  end

  vim.cmd 'wincmd p'
  return true
end

local function is_current_ai_window()
  local buftype = vim.bo.buftype
  local filetype = vim.bo.filetype

  return buftype == 'terminal' or filetype == 'opencode_ask'
end

local function is_ai_terminal(bufnr)
  local buftype = vim.bo[bufnr].buftype
  local filetype = vim.bo[bufnr].filetype
  local name = vim.api.nvim_buf_get_name(bufnr):lower()

  if filetype == 'opencode_ask' or name:find('claude', 1, true) or name:find('codex', 1, true) or name:find('opencode', 1, true) then
    return true
  end

  return
    buftype == 'terminal'
    and (name:find('claude', 1, true) or name:find('codex', 1, true) or name:find('opencode', 1, true))
end

local function close_provider(name)
  local provider = providers[name]
  if not provider then
    return
  end

  run_fn(provider.close_fn)
  run_fn(provider.stop_fn)
  run(provider.close, true)
  run(provider.stop, true)
end

function M.proxy_env()
  return {
    HTTP_PROXY = vim.env.PROXY,
    HTTPS_PROXY = vim.env.PROXY,
    NO_PROXY = 'localhost,127.0.0.1',
  }
end

function M.set_provider(name, opts)
  opts = opts or {}

  if not providers[name] then
    notify('Unknown provider: ' .. tostring(name), vim.log.levels.ERROR)
    return
  end

  for _, provider_name in ipairs(provider_order) do
    if provider_name ~= name then
      close_provider(provider_name)
    end
  end

  active_provider = name
  vim.g.ai_provider = name
  notify('Active provider: ' .. providers[name].label)

  if opts.open then
    M.open_chat()
  end
end

function M.select_provider()
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local conf = require('telescope.config').values

  pickers
    .new({}, {
      prompt_title = 'AI Provider',
      finder = finders.new_table {
        results = provider_order,
        entry_maker = function(name)
          local marker = name == active_provider and '* ' or '  '
          return {
            value = name,
            display = marker .. providers[name].label,
            ordinal = providers[name].label,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            M.set_provider(selection.value)
          end
        end)
        return true
      end,
    })
    :find()
end

function M.open_chat()
  local provider = current_provider()
  if run_fn(provider.open_fn) then
    return
  end

  run(provider.open)
end

function M.focus_chat()
  if is_current_ai_window() then
    focus_previous_editor_window()
    return
  end

  M.open_chat()
end

function M.send_selection()
  local provider = current_provider()
  if run_fn(provider.send_fn) then
    return
  end

  if not provider.send then
    notify(provider.label .. ' does not support sending selections from this integration', vim.log.levels.WARN)
    return
  end

  vim.cmd("'<,'>" .. provider.send)
end

function M.send_or_add_tree()
  local provider = current_provider()
  if run_fn(provider.tree_add_fn) then
    return
  end

  local command = provider.tree_add or provider.send

  if not command then
    notify(provider.label .. ' does not support adding context from this integration', vim.log.levels.WARN)
    return
  end

  run(command)
end

function M.add_current_buffer()
  local provider = current_provider()
  local path = vim.api.nvim_buf_get_name(0)

  if path == '' then
    notify('Current buffer has no file path', vim.log.levels.WARN)
    return
  end

  if run_fn(provider.add_fn) then
    return
  end

  if not provider.add then
    notify(provider.label .. ' does not support adding the current buffer from this integration', vim.log.levels.WARN)
    return
  end

  run_with_file(provider.add, path)
end

function M.accept_diff()
  local provider = current_provider()
  if not provider.diff_accept then
    notify(provider.label .. ' does not support diff accept from this integration', vim.log.levels.WARN)
    return
  end

  run(provider.diff_accept)
end

function M.deny_diff()
  local provider = current_provider()
  if not provider.diff_deny then
    notify(provider.label .. ' does not support diff deny from this integration', vim.log.levels.WARN)
    return
  end

  run(provider.diff_deny)
end

function M.setup_keymaps()
  vim.keymap.set('n', '<leader>ac', M.select_provider, { desc = '[A]I [C]hoose provider' })
  vim.keymap.set('n', '<leader>aa', M.open_chat, { desc = '[A]I [A]sk active provider' })
  vim.keymap.set('n', '<leader>af', M.focus_chat, { desc = '[A]I toggle [F]ocus' })
  vim.keymap.set('n', '<leader>ab', M.add_current_buffer, { desc = '[A]I add current [B]uffer' })
  vim.keymap.set('n', '<leader>as', M.send_or_add_tree, { desc = '[A]I [S]end tree file' })
  vim.keymap.set('x', '<leader>as', M.send_selection, { desc = '[A]I [S]end selection' })
  vim.keymap.set('n', '<leader>ay', M.accept_diff, { desc = '[A]I accept diff' })
  vim.keymap.set('n', '<leader>ad', M.deny_diff, { desc = '[A]I deny diff' })
end

function M.setup_terminal_keymaps()
  vim.api.nvim_create_autocmd({ 'TermOpen', 'FileType' }, {
    group = vim.api.nvim_create_augroup('AiTerminalKeymaps', { clear = true }),
    callback = function(event)
      if not is_ai_terminal(event.buf) then
        return
      end

      vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], {
        buffer = event.buf,
        desc = 'AI terminal window command',
      })
    end,
  })
end

return M
