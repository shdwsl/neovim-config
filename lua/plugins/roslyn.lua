-- roslyn
-- https://github.com/seblyng/roslyn.nvim

return {
  'seblyng/roslyn.nvim',
  ft = 'cs',
  init = function()
    vim.lsp.config('roslyn', {
      capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('cmp_nvim_lsp').default_capabilities()),
      settings = {
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
          dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
          dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
          dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
        },
        ['csharp|code_lens'] = {
          dotnet_enable_references_code_lens = true,
        },
      },
    })

    local augroup = vim.api.nvim_create_augroup('nvim-config-roslyn', { clear = true })
    local restore_handles = {}

    vim.api.nvim_create_autocmd('User', {
      group = augroup,
      pattern = 'RoslynRestoreProgress',
      callback = function(ev)
        local ok, progress = pcall(require, 'fidget.progress')
        local params = ev.data and ev.data.params
        if not ok or not params then
          return
        end

        local token = params[1]
        local state = params[2]
        local handle = restore_handles[token]
        if handle then
          handle:report {
            title = state.state,
            message = state.message,
          }
          return
        end

        restore_handles[token] = progress.handle.create {
          title = state.state,
          message = state.message,
          lsp_client = { name = 'roslyn' },
        }
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      group = augroup,
      pattern = 'RoslynRestoreResult',
      callback = function(ev)
        local token = ev.data and ev.data.token
        local handle = token and restore_handles[token]
        if not handle then
          return
        end

        restore_handles[token] = nil
        handle.message = ev.data.err and ev.data.err.message or 'Restore completed'
        handle:finish()
      end,
    })

    vim.api.nvim_create_user_command('CSFixUsings', function()
      local bufnr = vim.api.nvim_get_current_buf()
      local client = vim.lsp.get_clients({ name = 'roslyn', bufnr = bufnr })[1] or vim.lsp.get_clients({ name = 'roslyn' })[1]
      if not client then
        vim.notify("Couldn't find roslyn client", vim.log.levels.ERROR, { title = 'Roslyn' })
        return
      end

      local action = {
        kind = 'quickfix',
        data = {
          CustomTags = { 'RemoveUnnecessaryImports' },
          TextDocument = { uri = vim.uri_from_bufnr(bufnr) },
          CodeActionPath = { 'Remove unnecessary usings' },
          Range = {
            ['start'] = { line = 0, character = 0 },
            ['end'] = { line = 0, character = 0 },
          },
          UniqueIdentifier = 'Remove unnecessary usings',
        },
      }

      client:request('codeAction/resolve', action, function(err, resolved_action)
        if err or not resolved_action or not resolved_action.edit then
          vim.notify('Fix using directives failed', vim.log.levels.ERROR, { title = 'Roslyn' })
          return
        end

        vim.lsp.util.apply_workspace_edit(resolved_action.edit, client.offset_encoding)
      end, bufnr)
    end, { desc = 'Remove unnecessary C# using directives' })

    vim.api.nvim_create_user_command('CSRefreshDiagnostics', function()
      local clients = vim.lsp.get_clients { name = 'roslyn' }
      if not clients or vim.tbl_isempty(clients) then
        vim.notify("Couldn't find roslyn client", vim.log.levels.ERROR, { title = 'Roslyn' })
        return
      end

      for _, client in ipairs(clients) do
        local buffers = vim.lsp.get_buffers_by_client_id(client.id)
        for _, bufnr in ipairs(buffers) do
          local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
          client:request('textDocument/diagnostic', params, nil, bufnr)
        end
      end
    end, { desc = 'Refresh Roslyn diagnostics' })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = augroup,
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= 'roslyn' then
          return
        end

        local bufnr = args.buf
        vim.api.nvim_create_autocmd('InsertCharPre', {
          group = augroup,
          desc = "Roslyn: trigger auto insert on '/'.",
          buffer = bufnr,
          callback = function()
            local char = vim.v.char
            if char ~= '/' then
              return
            end

            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            local params = {
              _vs_textDocument = { uri = vim.uri_from_bufnr(bufnr) },
              _vs_position = { line = row - 1, character = col + 1 },
              _vs_ch = char,
              _vs_options = {
                tabSize = vim.bo[bufnr].tabstop,
                insertSpaces = vim.bo[bufnr].expandtab,
              },
            }

            vim.defer_fn(function()
              client:request('textDocument/_vs_onAutoInsert', params, function(err, result)
                if err or not result or not result._vs_textEdit then
                  return
                end

                vim.snippet.expand(result._vs_textEdit.newText)
              end, bufnr)
            end, 1)
          end,
        })
      end,
    })
  end,
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  opts = function()
    return {
      filewatching = 'auto',
      choose_target = nil,
      ignore_target = nil,
      broad_search = false,
      lock_target = false,
    }
  end,
}
