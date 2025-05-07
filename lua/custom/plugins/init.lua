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
  --   "olimorris/codecompanion.nvim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   opts = {
  --     strategies = {
  --       chat = {
  --         adapter = "ollama",
  --       },
  --       inline = {
  --         adapter = "ollama",
  --       },
  --       cmd = {
  --         adapter = "ollama"
  --       }
  --     },
  --     adapters = {
  --       ollama = function()
  --         return require("codecompanion.adapters").extend("ollama", {
  --           env = {
  --             url = "http://192.168.31.133:11434"
  --           },
  --           schema = {
  --             model = {
  --               default = "qwen2.5-coder:7b"
  --             }
  --           }
  --         })
  --       end
  --     },
  --     opts = {
  --       -- Set debug logging
  --       log_level = "DEBUG",
  --     },
  --   },
  -- },
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = 'ollama',
      ollama = {
        endpoint = "http://192.168.31.133:11434",
        model = "qwen2.5-coder:latest",
        temperature = 0,
        max_tokens = 32768,
      },
      vendors = {
        openrouter = {
          __inherited_from = 'openai',
          api_key_name = 'OPENROUTER_API_KEY',
          endpoint = 'https://openrouter.ai/api/v1',
          model = 'anthropic/claude-3.7-sonnet', -- your desired model (or use gpt-4o, etc.)
          -- timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
          -- temperature = 0,
          -- max_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
          -- reasoning_effort = 'medium', -- low|medium|high, only used for reasoning models
        },
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- build = 'make',
    build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false", -- for windows
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'echasnovski/mini.pick',         -- for file_selector provider mini.pick
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'hrsh7th/nvim-cmp',              -- autocompletion for avante commands and mentions
      'ibhagwan/fzf-lua',              -- for file_selector provider fzf
      'nvim-tree/nvim-web-devicons',   -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua',        -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  }
}
