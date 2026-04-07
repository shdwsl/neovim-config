return {
  'akinsho/toggleterm.nvim',
  config = function()
    require('toggleterm').setup {
      open_mapping = [[<leader>tt]],
      shell = 'nu',
      direction = 'horizontal',
      size = function()
        return vim.o.lines * 0.4
      end,
    }
  end,
}
