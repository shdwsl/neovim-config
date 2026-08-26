if vim.g.vscode then
  require 'config.vscode'
else
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ','

  vim.g.have_nerd_font = true

  vim.opt.number = true

  vim.opt.relativenumber = true

  vim.opt.mouse = 'a'

  vim.opt.showmode = false

  vim.opt.clipboard = 'unnamedplus'

  vim.opt.breakindent = true

  vim.opt.undofile = true

  vim.opt.ignorecase = true
  vim.opt.smartcase = true

  vim.opt.signcolumn = 'yes'

  vim.opt.updatetime = 250

  vim.opt.timeoutlen = 300

  vim.opt.splitright = true
  vim.opt.splitbelow = true

  vim.opt.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
    desc = 'Hide carriage return characters at line ends',
    group = vim.api.nvim_create_augroup('nvim-config-hide-cr', { clear = true }),
    callback = function()
      if vim.fn.search([[\r$]], 'nw') == 0 then
        return
      end

      vim.wo.conceallevel = math.max(vim.wo.conceallevel, 2)
      if vim.w.hide_cr_match_id then
        pcall(vim.fn.matchdelete, vim.w.hide_cr_match_id)
      end
      vim.w.hide_cr_match_id = vim.fn.matchadd('Conceal', [[\r$]], 10, -1, { conceal = '' })
    end,
  })

  vim.opt.inccommand = 'split'

  vim.opt.cursorline = true

  vim.opt.scrolloff = 10

  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4

  vim.opt.hlsearch = true

  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
  vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save' })

  vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = 'rounded',
      source = 'always',
      header = '',
      prefix = '',
    },
  }

  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation' })
  vim.keymap.set('n', '<leader>k', vim.diagnostic.open_float, { desc = 'Show diagnostic [K]message' })

  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('nvim-config-highlight-yank', { clear = true }),
    callback = function()
      vim.highlight.on_yank()
    end,
  })

  local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
  if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
      error('Error cloning lazy.nvim:\n' .. out)
    end
  end
  vim.opt.rtp:prepend(lazypath)

  require('lazy').setup({
    {
      'catppuccin/nvim',
      name = 'catppuccin',
      priority = 1000,
      config = function()
        require('catppuccin').setup {
          background = {
            light = 'latte',
            dark = 'macchiato',
          },
          integrations = {
            cmp = true,
            gitsigns = true,
            mason = true,
            mini = true,
            native_lsp = { enabled = true },
            noice = true,
            notify = true,
            telescope = { enabled = true },
            treesitter = true,
            trouble = true,
            which_key = true,
          },
        }

        vim.cmd.colorscheme 'catppuccin'

        -- Neovim 0.10+ queries the terminal background color (OSC 11) and sets
        -- 'background' automatically; re-apply the colorscheme when it changes.
        vim.api.nvim_create_autocmd('OptionSet', {
          pattern = 'background',
          desc = 'Sync colorscheme with terminal background',
          group = vim.api.nvim_create_augroup('nvim-config-sync-appearance', { clear = true }),
          callback = function()
            vim.cmd.colorscheme 'catppuccin'
          end,
        })
      end,
    },
    'tpope/vim-sleuth',
    {
      'lewis6991/gitsigns.nvim',
      opts = {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      },
    },

    {
      'folke/which-key.nvim',
      event = 'VimEnter',
      config = function()
        require('which-key').setup()

        require('which-key').add {
          { '<leader>a', group = '[A]I' },
          { '<leader>c', group = '[C]ode' },
          { '<leader>d', group = '[D]ocument' },
          { '<leader>r', group = '[R]ename' },
          { '<leader>s', group = '[S]earch' },
          { '<leader>w', group = '[W]orkspace' },
          { '<leader>t', group = '[T]oggle' },
          { '<leader>l', group = '[L]azy Git|Trouble' },
          { '<leader>x', group = 'Trouble' },
          { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        }
      end,
    },
    {
      'folke/trouble.nvim',
      opts = {},
      cmd = 'Trouble',
      keys = {
        {
          '<leader>xx',
          '<cmd>Trouble diagnostics toggle<cr>',
          desc = 'Diagnostics (Trouble)',
        },
        {
          '<leader>xX',
          '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
          desc = 'Buffer Diagnostics (Trouble)',
        },
        {
          '<leader>cs',
          '<cmd>Trouble symbols toggle focus=false<cr>',
          desc = 'Symbols (Trouble)',
        },
        {
          '<leader>cl',
          '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
          desc = 'LSP Definitions / references / ... (Trouble)',
        },
        {
          '<leader>xL',
          '<cmd>Trouble loclist toggle<cr>',
          desc = 'Location List (Trouble)',
        },
        {
          '<leader>xQ',
          '<cmd>Trouble qflist toggle filter.buf=0<cr>',
          desc = 'Quickfix List Buffer (Trouble)',
        },
      },
    },

    {
      'nvim-telescope/telescope.nvim',
      event = 'VimEnter',
      branch = 'master',
      dependencies = {
        'nvim-lua/plenary.nvim',
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          build = 'make',
          cond = function()
            return vim.fn.executable 'make' == 1
          end,
        },
        { 'nvim-telescope/telescope-ui-select.nvim' },

        { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      },
      config = function()
        require('telescope').setup {
          defaults = {
            file_ignore_patterns = {
              '.cache',
              '.git\\',
              '.node_modules\\',
              '\\Library\\*',
              '\\Temp\\*',
              '\\Obj\\*',
              '\\Logs\\*',
              '%.meta$',
            },
          },
          pickers = {
            find_files = {
              hidden = true,
              file_ignore_patterns = { '.git/', 'node_modules' },
            },
          },
          extensions = {
            ['ui-select'] = {
              require('telescope.themes').get_dropdown(),
            },
          },
        }

        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')

        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
        vim.keymap.set('n', '<leader>sf', function()
          builtin.find_files(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
        vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

        vim.keymap.set('n', '<leader>/', function()
          builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end, { desc = '[/] Fuzzily search in current buffer' })

        vim.keymap.set('n', '<leader>s/', function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end, { desc = '[S]earch [/] in Open Files' })

        vim.keymap.set('n', '<leader>sn', function()
          builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, { desc = '[S]earch [N]eovim files' })
      end,
    },
    {
      'neovim/nvim-lspconfig',
      dependencies = {

        { 'williamboman/mason.nvim', config = true },
        'williamboman/mason-lspconfig.nvim',
        {
          'WhoIsSethDaniel/mason-tool-installer.nvim',
          opts = {
            ensure_installed = {
              'taplo',
              'yamlls',
              'jsonls',
              'lua_ls',
              'stylua',
            },
          },
        },

        { 'j-hui/fidget.nvim', opts = {} },

        {
          'folke/lazydev.nvim',
          ft = 'lua',
          opts = {
            library = {

              { path = 'luvit-meta/library', words = { 'vim%.uv' } },
            },
          },
        },
        { 'Bilal2453/luvit-meta', lazy = true },
        { 'b0o/schemastore.nvim' },
        { 'Issafalcon/lsp-overloads.nvim' },
      },
      config = function()
        -- Nvim 0.12 provides the native `:lsp` command, which makes
        -- nvim-lspconfig skip its legacy LspInfo/LspLog aliases. Keep the
        -- useful inspection commands available across Nvim versions.
        if vim.fn.exists ':LspLog' == 0 then
          vim.api.nvim_create_user_command('LspLog', function()
            vim.cmd.tabnew(vim.fn.fnameescape(vim.lsp.log.get_filename()))
          end, { desc = 'Open the Nvim LSP client log' })
        end
        if vim.fn.exists ':LspInfo' == 0 then
          vim.api.nvim_create_user_command('LspInfo', 'checkhealth vim.lsp', { desc = 'Show LSP health and clients' })
        end

        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('nvim-config-lsp-attach', { clear = true }),
          callback = function(event)
            local map = function(keys, func, desc)
              vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
            end

            map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

            map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

            map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

            map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

            map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

            map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

            map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

            map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

            local client = vim.lsp.get_client_by_id(event.data.client_id)

            if client and client.server_capabilities.signatureHelpProvider then
              require('lsp-overloads').setup(client, {})
            end

            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
              local highlight_augroup = vim.api.nvim_create_augroup('nvim-config-lsp-highlight', { clear = false })
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
              })

              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
              })

              vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('nvim-config-lsp-detach', { clear = true }),
                callback = function(event2)
                  vim.lsp.buf.clear_references()
                  vim.api.nvim_clear_autocmds { group = 'nvim-config-lsp-highlight', buffer = event2.buf }
                end,
              })
            end

            if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
              map('<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
              end, '[T]oggle Inlay [H]ints')
            end
          end,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        local servers = {

          -- TOML (schemas/validation via its built-in SchemaStore catalog)
          taplo = {},

          -- YAML (schemas via schemastore.nvim, same as jsonls)
          yamlls = {
            settings = {
              yaml = {
                -- disable yamlls' built-in store, use schemastore.nvim instead
                schemaStore = { enable = false, url = '' },
                schemas = require('schemastore').yaml.schemas(),
                validate = true,
                hover = true,
                completion = true,
              },
            },
          },

          jsonls = {
            settings = {
              json = {
                schemas = require('schemastore').json.schemas(),
                validate = { enable = true },
              },
            },
          },
          lua_ls = {

            settings = {
              Lua = {
                completion = {
                  callSnippet = 'Replace',
                },
              },
            },
          },
        }

        require('mason').setup()

        -- mason-lspconfig v2 has no `handlers`; it auto-enables mason-installed
        -- servers instead. Layer cmp capabilities on every server, then apply
        -- per-server settings on top of the nvim-lspconfig defaults.
        vim.lsp.config('*', { capabilities = capabilities })
        for server_name, server in pairs(servers) do
          vim.lsp.config(server_name, server)
        end

        require('mason-lspconfig').setup()
      end,
    },

    {
      'stevearc/conform.nvim',
      cmd = { 'ConformInfo' },
      keys = {
        {
          '<leader>f',
          function()
            require('conform').format { async = true, lsp_fallback = true }
          end,
          mode = '',
          desc = '[F]ormat buffer',
        },
      },
      opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
          local disable_filetypes = { c = true, cpp = true, cs = true }
          return {
            timeout_ms = 500,
            lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
          }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
        },
      },
    },

    {
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',
      dependencies = {

        {
          'L3MON4D3/LuaSnip',
          build = (function()
            if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
              return
            end
            return 'make install_jsregexp'
          end)(),
          dependencies = {

            {
              'rafamadriz/friendly-snippets',
              config = function()
                require('luasnip.loaders.from_vscode').lazy_load()
              end,
            },
          },
        },
        'saadparwaiz1/cmp_luasnip',

        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lsp-document-symbol',
        'hrsh7th/cmp-nvim-lsp-signature-help',
      },
      config = function()
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'
        luasnip.config.setup {}

        cmp.setup {
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          completion = { completeopt = 'menu,menuone,noinsert' },

          mapping = cmp.mapping.preset.insert {

            ['<C-j>'] = cmp.mapping.select_next_item(),

            ['<C-k>'] = cmp.mapping.select_prev_item(),

            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),

            ['<CR>'] = cmp.mapping.confirm { select = true },

            ['<C-Space>'] = cmp.mapping.complete {},

            ['<C-l>'] = cmp.mapping(function()
              if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              end
            end, { 'i', 's' }),
            ['<C-h>'] = cmp.mapping(function()
              if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              end
            end, { 'i', 's' }),
          },
          sources = {
            {
              name = 'lazydev',

              group_index = 0,
            },
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'path' },
            { name = 'buffer' },
            { name = 'nvim_lsp_document_symbol' },
            { name = 'nvim_lsp_signature_help ' },
          },
        }
      end,
    },

    { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

    {
      'echasnovski/mini.nvim',
      config = function()
        require('mini.ai').setup { n_lines = 500 }

        require('mini.surround').setup()

        local statusline = require 'mini.statusline'

        statusline.setup { use_icons = vim.g.have_nerd_font }

        statusline.section_location = function()
          return '%2l:%-2v'
        end
      end,
    },
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      opts = {
        ensure_installed = {
          'bash',
          'c',
          'cpp',
          'c_sharp',
          'diff',
          'html',
          'lua',
          'luadoc',
          'markdown',
          'markdown_inline',
          'query',
          'rust',
          'toml',
          'vim',
          'vimdoc',
          'yaml',
        },

        auto_install = true,
        highlight = {
          enable = true,

          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent = { enable = true, disable = { 'ruby' } },
      },
      config = function(_, opts)
        require('nvim-treesitter.install').prefer_git = true

        require('nvim-treesitter').setup(opts)
      end,
    },
    require 'plugins',
  }, {

    ui = {
      icons = vim.g.have_nerd_font and {} or {
        cmd = '⌘',
        config = '🛠',
        event = '📅',
        ft = '📂',
        init = '⚙',
        keys = '🗝',
        plugin = '🔌',
        runtime = '💻',
        require = '🌙',
        source = '📄',
        start = '🚀',
        task = '📌',
        lazy = '💤 ',
      },
    },
  })
end
