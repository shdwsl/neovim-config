local ai = require 'config.ai'

local function opencode_command()
  return 'OPENCODE_CONFIG=' .. vim.fn.shellescape(vim.fn.stdpath 'config' .. '/opencode.jsonc') .. ' opencode --port'
end

return {
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    lazy = false,
    init = function()
      ai.setup_keymaps()
      ai.setup_terminal_keymaps()
    end,
    opts = {
      auto_start = false,
      env = ai.proxy_env(),
      terminal = {
        split_width_percentage = 0.45,
      },
    },
  },
  {
    'ishiooon/codex.nvim',
    dependencies = { 'folke/snacks.nvim' },
    lazy = false,
    opts = {
      auto_start = false,
      keymaps = {
        enabled = false,
      },
      env = ai.proxy_env(),
      terminal = {
        split_width_percentage = 0.45,
      },
    },
  },
  {
    'nickjvandyke/opencode.nvim',
    version = '*',
    dependencies = { 'folke/snacks.nvim' },
    lazy = false,
    config = function()
      vim.g.opencode_opts = {
        server = {
          start = function()
            require('opencode.terminal').start(opencode_command(), {
              split = 'right',
              width = math.floor(vim.o.columns * 0.45),
            })
          end,
          stop = function()
            require('opencode.terminal').stop()
          end,
          toggle = function()
            require('opencode.terminal').toggle(opencode_command(), {
              split = 'right',
              width = math.floor(vim.o.columns * 0.45),
            })
          end,
        },
      }
      vim.o.autoread = true
    end,
  },
}
