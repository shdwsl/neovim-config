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
				open_mapping = [[<leader>tt]],
				shell = 'nu',
				direction = 'horizontal',
				size = function()
					return vim.o.lines * 0.4
				end,
			}
		end,
	},
	-- {
	-- 	'LhKipp/nvim-nu',
	-- 	config = function()
	-- 		require('nu').setup {
	-- 			use_lsp_features = false,
	-- 		}
	-- 	end,
	-- },
}
