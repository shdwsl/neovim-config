return {
  'nvim-neorg/neorg',
  lazy = false,
  version = '9.1.1',
  config = function()
    require('neorg').setup {
      load = {
        ['core.defaults'] = {},
        ['core.concealer'] = {},
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = '~/notes',
            },
            default_workspace = 'notes',
          },
        },
        ['core.integrations.telescope'] = {},
        ['core.todo-introspector'] = {},
      },
    }
    vim.wo.foldlevel = 99
    vim.wo.conceallevel = 2
  end,
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-neorg/neorg-telescope' },
  },
}
