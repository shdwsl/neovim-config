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

  -- Debugging: netcoredbg adapter + C# launch/attach configurations.
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    keys = {
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
        desc = 'Debug: Start/Continue',
      },
      {
        '<F1>',
        function()
          require('dap').step_into()
        end,
        desc = 'Debug: Step Into',
      },
      {
        '<F2>',
        function()
          require('dap').step_over()
        end,
        desc = 'Debug: Step Over',
      },
      {
        '<F3>',
        function()
          require('dap').step_out()
        end,
        desc = 'Debug: Step Out',
      },
      {
        '<leader>b',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Debug: Toggle Breakpoint',
      },
      {
        '<leader>B',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      {
        '<F7>',
        function()
          require('dapui').toggle()
        end,
        desc = 'Debug: See last session result',
      },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Registers the `coreclr` adapter from mason's netcoredbg.
      require('mason-nvim-dap').setup {
        automatic_installation = true,
        ensure_installed = { 'netcoredbg' },
        handlers = {},
      }

      dap.configurations.cs = {
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
