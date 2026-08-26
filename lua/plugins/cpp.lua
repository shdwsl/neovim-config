-- C / C++ development environment
--
-- Everything C/C++-related lives in this file. To disable all of it,
-- comment out `require 'plugins.cpp'` in lua/plugins/init.lua.
--
-- Tools (clangd and clang-format) are auto-installed via mason. CMake itself
-- and a C/C++ compiler must be installed by the system package manager.

return {
  -- Keep C/C++ tools tied to this module so disabling it also stops Mason
  -- from installing them.
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'clangd', 'clang-format' })
    end,
  },

  -- clangd LSP plus extra AST and type-hierarchy commands.
  {
    'p00f/clangd_extensions.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
    },
    init = function()
      local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())

      -- mason-lspconfig auto-enables clangd; configure it before the first
      -- C/C++ buffer is opened so only one client is started.
      vim.lsp.config('clangd', {
        capabilities = capabilities,
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--completion-style=detailed',
          '--header-insertion=iwyu',
          '--function-arg-placeholders',
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })
    end,
    opts = {},
  },

  -- Configure, build, run, and select CMake targets from Neovim.
  -- Use `:CMake<Tab>` to browse the available commands.
  {
    'Civitasv/cmake-tools.nvim',
    ft = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'cmake' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },

  -- Formatting via clang-format (<leader>f and format-on-save).
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.c = { 'clang_format' }
      opts.formatters_by_ft.cpp = { 'clang_format' }
      opts.formatters_by_ft.objc = { 'clang_format' }
      opts.formatters_by_ft.objcpp = { 'clang_format' }
      opts.formatters_by_ft.cuda = { 'clang_format' }
    end,
  },
}
