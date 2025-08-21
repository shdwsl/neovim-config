return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = function()
    vim.keymap.set("", "<leader>aa", "<cmd>CodeCompanionActions<CR>", { desc = "Code Companion Actions" })

    return {
      strategies = {
        chat = {
          adapter = "openrouter",
        },
        inline = {
          adapter = "openrouter",
        },
        cmd = {
          adapter = "openrouter",
        }
      },
      adapters = {
        lmstudio = function()
          return require 'codecompanion.adapters'.extend("openai_compatible", {
            env = {
              url = "http://localhost:1234",
            },
            schema = {
              model = {
                default = "qwen/qwen3-8b",
              }
            }
          })
        end,

        openrouter = function()
          return require 'codecompanion.adapters'.extend("openai_compatible", {
            env = {
              url = "https://openrouter.ai/api",
              api_key = "OPENROUTER_API_KEY",
              chat_url = "/v1/chat/completions"
            },
            schema = {
              model = {
                default = "anthropic/claude-3.7-sonnet",
              }
            }
          })
        end
      },
      display = {
        diff = {
          enabled = true,
        }
      },
      opts = {
        -- Set debug logging
        log_level = "DEBUG",
      },
    }
  end,
}
