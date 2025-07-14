return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = function()
    vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionActions<CR>", { desc = "Code Companion Actions" })

    return {
      strategies = {
        chat = {
          adapter = "lmstudio",
        },
        inline = {
          adapter = "lmstudio",
        },
        cmd = {
          adapter = "lmstudio"
        }
      },
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            env = {
              url = "http://192.168.31.133:11434"
            },
            schema = {
              model = {
                default = "qwen2.5-coder:7b"
              }
            }
          })
        end,
        lmstudio = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "http://127.0.0.1:1234"
            },
            schema = {
              model = {
                default = "qwen/qwen3-8b"
              }
            }
          })
        end,
        claude_openrouter = function()
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
