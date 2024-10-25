vim.g.mapleader = ' '
vim.g.have_nerd_font = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

local vscode = require 'vscode'
vim.keymap.set('n', '<leader>f', function()
  vscode.action 'editor.action.formatDocument'
end)
vim.keymap.set('n', '<leader>ww', ':w<CR>')
vim.keymap.set('n', '<leader><leader>', function()
  vscode.action 'workbench.action.showAllEditors'
end)
vim.keymap.set('n', '<leader>ca', function()
  vscode.action 'editor.action.quickFix'
end)
vim.keymap.set('n', '\\', function()
  vscode.action 'workbench.action.toggleSidebarVisibility'
end)
vim.keymap.set('n', '<leader>sf', function()
  vscode.action 'workbench.action.quickOpen'
end)
vim.keymap.set('n', '<leader>ds', function()
  vscode.action 'workbench.action.gotoSymbol'
end)
vim.keymap.set('n', '<leader>ws', function()
  vscode.action 'workbench.action.showAllSymbols'
end)
vim.keymap.set('n', "<leader>tg", function ()
  vscode.action 'workbench.view.scm'
end)
vim.keymap.set('n', "<leader>te", function ()
  vscode.action 'workbench.view.explorer'
end)
vim.keymap.set('n', "<leader>td", function ()
  vscode.action 'workbench.view.debug'
end)
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
