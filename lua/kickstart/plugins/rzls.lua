-- rzls
-- https://github.com/tris203/rzls.nvim

return {
  'tris203/rzls.nvim',
  config = function()
    require('rzls').setup {
      enable_autocmd = true, -- Automatically attach to Razor files (optional)
      lsp_opts = {
        on_attach = function(client, bufnr)
          -- Custom on_attach for Razor LSP
          print('Razor-LS attached to buffer ' .. bufnr)
        end,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        handlers = require 'rzls.roslyn_handlers',
        settings = {
          razor = {
            includeLanguages = { 'cshtml' },
          },
        },
      },
    }

    require('roslyn').setup {
      args = {
        '--logLevel=Information',
        '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
        '--razorSourceGenerator='
          .. vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'packages', 'roslyn', 'libexec', 'Microsoft.CodeAnalysis.Razor.Compiler.dll'),
        '--razorDesignTimePath='
          .. vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'packages', 'rzls', 'libexec', 'Targets', 'Microsoft.NET.Sdk.Razor.DesignTime.targets'),
      },
      config = {
        on_attach = function(client, bufnr) end,
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
        handlers = require 'rzls.roslyn_handlers',
      },
    }
  end,
  dependencies = {
    'neovim/nvim-lspconfig',
    'hrsh7th/cmp-nvim-lsp', -- For autocompletion support (optional)
  },
}
