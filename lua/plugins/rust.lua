-- Rust development environment
--
-- Everything Rust-related lives in this file. To disable all of it,
-- comment out `require 'plugins.rust'` in lua/plugins/init.lua.
--
-- Requires the Rust toolchain (NOT managed by mason):
--   sudo pacman -S rustup
--   rustup default stable
--   rustup component add rust-analyzer clippy rustfmt
-- The debugger (codelldb) is auto-installed via mason (see init.lua);
-- the dap core lives in lua/plugins/debug.lua.
--
-- NOTE: do NOT install rust-analyzer via mason -- rustaceanvim spawns the
-- rustup-provided one itself; a mason copy would attach a duplicate client.

return {
  -- rust-analyzer on steroids: LSP, extra commands, DAP integration.
  -- `:RustLsp <tab>` gives you: runnables, debuggables, expandMacro,
  -- rebuildProcMacros, explainError, renderDiagnostic, openCargo, ...
  {
    'mrcjkb/rustaceanvim',
    version = '^9',
    lazy = false, -- the plugin lazy-loads itself
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    init = function()
      vim.g.rustaceanvim = {
        server = {
          capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities()),
          default_settings = {
            ['rust-analyzer'] = {
              cargo = { allFeatures = true },
              check = { command = 'clippy' },
              checkOnSave = true,
              procMacro = { enable = true },
            },
          },
        },
        -- codelldb from mason + nvim-dap are detected automatically
        dap = {},
      }
    end,
  },

  -- Cargo.toml dependencies: inline version hints, completion, updates.
  -- `:Crates <tab>` for commands (update, upgrade, features, ...).
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    opts = {
      completion = {
        cmp = { enabled = true },
      },
    },
  },
}
