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
          '--function-arg-placeholders=true',
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
    init = function()
      -- Configure and build the current CMake project, expose its compilation
      -- database to clangd, then restart clangd so diagnostics are refreshed.
      vim.api.nvim_create_user_command('CMakeSetupLsp', function()
        local source = vim.api.nvim_buf_get_name(0)
        local root = vim.fs.root(source ~= '' and source or vim.fn.getcwd(), 'CMakeLists.txt')
        if not root then
          vim.notify('No CMakeLists.txt found', vim.log.levels.ERROR)
          return
        end

        local build_dir = root .. '/build'
        local compile_commands = build_dir .. '/compile_commands.json'
        local link = root .. '/compile_commands.json'

        local function run(command, on_success)
          vim.system(command, { cwd = root, text = true }, function(result)
            vim.schedule(function()
              if result.code ~= 0 then
                local output = result.stderr ~= '' and result.stderr or result.stdout
                vim.notify(table.concat(command, ' ') .. ' failed:\n' .. vim.trim(output or ''), vim.log.levels.ERROR)
                return
              end
              on_success()
            end)
          end)
        end

        vim.notify 'Configuring CMake project for clangd…'
        run({
          'cmake',
          '-S',
          root,
          '-B',
          build_dir,
          '-DCMAKE_BUILD_TYPE=Debug',
          '-DCMAKE_EXPORT_COMPILE_COMMANDS=ON',
        }, function()
          vim.notify 'Building CMake project…'
          run({ 'cmake', '--build', build_dir }, function()
            if not vim.uv.fs_stat(compile_commands) then
              vim.notify('CMake did not generate compile_commands.json', vim.log.levels.ERROR)
              return
            end

            local existing = vim.uv.fs_lstat(link)
            if existing then
              if existing.type == 'directory' then
                vim.notify(link .. ' is a directory and cannot be replaced', vim.log.levels.ERROR)
                return
              end
              vim.uv.fs_unlink(link)
            end

            local ok, err = vim.uv.fs_symlink(compile_commands, link)
            if not ok then
              vim.notify('Could not link compile_commands.json: ' .. (err or 'unknown error'), vim.log.levels.ERROR)
              return
            end

            vim.cmd 'lsp restart clangd'
            vim.notify 'CMake build complete; clangd restarted'
          end)
        end)
      end, { desc = 'Configure/build CMake and refresh clangd' })
    end,
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
