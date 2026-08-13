-- C# / Unity development environment
--
-- Everything C#-related lives in this file. To disable all of it,
-- comment out `require 'plugins.csharp'` in lua/plugins/init.lua.
--
-- Notes:
--   * Tools (omnisharp, netcoredbg, csharpier) are auto-installed via mason
--     (see ensure_installed in init.lua).
--   * For Unity: set Unity's external editor to Neovim and click
--     "Regenerate project files" (Edit > Preferences > External Tools) so the
--     .sln/.csproj files OmniSharp needs are generated.
--   * netcoredbg debugs plain .NET (CoreCLR) apps. The Unity editor runs on
--     the Mono runtime, so the editor itself cannot be debugged with netcoredbg.

return {
  -- Go to definition into decompiled sources (Unity APIs, .NET BCL) instead of
  -- metadata stubs, plus better references/implementations via Telescope.
  {
    'Hoffs/omnisharp-extended-lsp.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      local capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities())

      -- OmniSharp LSP. mason-lspconfig auto-enables mason-installed servers;
      -- vim.lsp.config layers our settings on top of the nvim-lspconfig defaults.
      vim.lsp.config('omnisharp', {
        capabilities = capabilities,
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = true,
          },
          MsBuild = {
            LoadProjectsOnDemand = false,
          },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
            EnableDecompilationSupport = true,
            AnalyzeOpenDocumentsOnly = false,
          },
          InlayHintsOptions = {
            EnableForParameters = true,
            ForLiteralParameters = true,
            ForIndexerParameters = true,
            ForObjectCreationParameters = true,
            ForOtherParameters = true,
            EnableForTypes = true,
            ForImplicitVariableTypes = true,
            ForLambdaParameterTypes = true,
            ForImplicitObjectCreation = true,
          },
          Sdk = {
            IncludePrereleases = true,
          },
        },
      })

      -- Route navigation through omnisharp-extended so definitions land in
      -- decompiled source. Overrides the generic LSP maps from init.lua,
      -- but only in buffers attached to omnisharp.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('nvim-config-omnisharp', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= 'omnisharp' then
            return
          end

          local map = function(keys, fn, desc)
            vim.keymap.set('n', keys, fn, { buffer = args.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('omnisharp_extended').telescope_lsp_definitions, '[G]oto [D]efinition (decompiled)')
          map('gr', require('omnisharp_extended').telescope_lsp_references, '[G]oto [R]eferences')
          map('gI', require('omnisharp_extended').telescope_lsp_implementation, '[G]oto [I]mplementation')
          map('<leader>D', require('omnisharp_extended').telescope_lsp_type_definition, 'Type [D]efinition')
        end,
      })
    end,
  },

  -- C# debug configurations, registered when the shared dap core
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
      -- dap configurations are defined in the nvim-dap spec above
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
