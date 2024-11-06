vim.g.mapleader = ' '
vim.g.have_nerd_font = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>ww', ':w<CR>')

local vscode = require 'vscode'

local set_vscode_action = function(mode, key, action)
  vim.keymap.set(mode, key, function()
    vscode.action(action)
  end)
end

set_vscode_action('n', '<leader>f', 'editor.action.formatDocument')
set_vscode_action('v', '<leader>f', 'editor.action.formatSelection')
set_vscode_action('n', '<leader><leader>', 'workbench.action.showAllEditors')
set_vscode_action('n', '<leader>ca', 'editor.action.quickFix')
set_vscode_action('n', '\\', 'workbench.action.toggleSidebarVisibility')
set_vscode_action('n', '<leader>sf', 'workbench.action.quickOpen')
set_vscode_action('n', '<leader>ds', 'workbench.action.gotoSymbol')
set_vscode_action('n', '<leader>ws', 'workbench.action.showAllSymbols')
set_vscode_action('n', '<leader>tg', 'workbench.view.scm')
set_vscode_action('n', '<leader>te', 'workbench.view.explorer')
set_vscode_action('n', '<leader>td', 'workbench.view.debug')
set_vscode_action('n', 'gI', 'editor.action.goToImplementation')
set_vscode_action('n', '<leader>rn', 'editor.action.rename')

-- vim.keymap.set({ 'i', 'n' }, 'C-j', function()
--   local suggestWidgetMultipleSuggestions = vscode.eval 'return vscode.suggestWidgetMultipleSuggestions'
--   local suggestWidgetVisible = vscode.eval 'return vscode.suggestWidgetVisible'
--   local textInputFocus = vscode.eval 'return vscode.textInputFocus'
--   print(suggestWidgetVisible)
--
--   if suggestWidgetMultipleSuggestions and suggestWidgetVisible and textInputFocus then
--     vscode.action 'selectNextSuggestion'
--     print 'gop'
--   end
-- end)
