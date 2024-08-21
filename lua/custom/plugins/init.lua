-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup {
        enable = true,
        max_lines = 10,
      }
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    config = function()
      require('toggleterm').setup {
        open_mapping = [[<C-\>]],
        shell = 'nu',
      }
    end,
  },
  {
    'LhKipp/nvim-nu',
    config = function()
      require('nu').setup {}
    end,
  },
}
