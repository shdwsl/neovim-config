-- C# / Unity development environment
--
-- Everything C#-related lives in this file. To disable all of it,
-- comment out `require 'plugins.csharp'` in lua/plugins/init.lua.
--
-- Notes:
--   * Tools (Roslyn, netcoredbg, csharpier) are auto-installed via Mason.
--   * For Unity: set Unity's external editor and regenerate project files so
--     the .sln/.csproj files Roslyn needs are up to date.
--   * netcoredbg debugs plain .NET (CoreCLR) apps. The Unity editor runs on
--     the Mono runtime, so the editor itself cannot be debugged with it.

return {
  -- Keep C# tools tied to this module so disabling it also stops Mason from
  -- installing them. `roslyn-language-server` is the official Mason package.
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { 'roslyn-language-server', 'netcoredbg', 'csharpier' })
    end,
  },

  -- Modern Roslyn language server, matching the server architecture used by
  -- the VS Code C# extension. roslyn.nvim adds solution selection, generated
  -- source/decompiled-file support, and correct project initialization.
  {
    'seblyng/roslyn.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
    },
    opts = {
      -- Let Roslyn watch the large Unity workspace instead of registering a
      -- large set of Neovim/libuv watchers.
      filewatching = 'roslyn',
      broad_search = false,
      lock_target = false,
    },
    config = function(_, opts)
      local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())

      vim.lsp.config('roslyn', {
        capabilities = capabilities,
        settings = {
          -- Analyze open documents instead of retaining diagnostics and
          -- analyzer state for every generated Unity project.
          ['csharp|background_analysis'] = {
            dotnet_analyzer_diagnostics_scope = 'openFiles',
            dotnet_compiler_diagnostics_scope = 'openFiles',
          },
          ['csharp|completion'] = {
            dotnet_show_completion_items_from_unimported_namespaces = true,
            dotnet_show_name_completion_suggestions = true,
          },
          ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
          },
          ['csharp|symbol_search'] = {
            dotnet_search_reference_assemblies = true,
          },
          ['csharp|formatting'] = {
            dotnet_organize_imports_on_format = true,
          },
        },
      })

      require('roslyn').setup(opts)
    end,
  },

  -- C# debug configurations, registered when the shared DAP core
  -- (lua/plugins/debug.lua) loads. The `coreclr` adapter (netcoredbg)
  -- is set up there via mason-nvim-dap.
  {
    'mfussenegger/nvim-dap',
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyLoad',
        group = vim.api.nvim_create_augroup('nvim-config-csharp-dap', { clear = true }),
        callback = function(ev)
          if ev.data ~= 'nvim-dap' then
            return
          end

          require('dap').configurations.cs = {
            {
              type = 'coreclr',
              name = 'Launch .NET app',
              request = 'launch',
              program = function()
                return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
              end,
            },
            {
              type = 'coreclr',
              name = 'Attach to process',
              request = 'attach',
              processId = require('dap.utils').pick_process,
            },
          }
        end,
      })
    end,
  },

  -- .NET CLI integration: build/run/test, NuGet browser, project/solution
  -- management, templates. Run `:Dotnet` to see everything.
  {
    'GustavEikaas/easy-dotnet.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
    cmd = 'Dotnet',
    opts = {
      -- roslyn.nvim owns the language server; prevent easy-dotnet from
      -- starting a duplicate Roslyn client.
      lsp = { enabled = false },
      -- DAP configurations are defined in the nvim-dap spec above.
      debugger = { auto_register_dap = false },
    },
  },

  -- Formatting: csharpier via conform (<leader>f and format-on-save).
  {
    'stevearc/conform.nvim',
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.cs = { 'csharpier' }
    end,
  },
}
