vim.api.nvim_buf_set_option(0, 'makeprg', 'dotnet build')
vim.api.nvim_buf_create_user_command(0, 'CodeDocModeEnter', require('mode-codedoc'), {force = true})
vim.keymap.set('n', '<Leader>c', '<Cmd>CodeDocModeEnter<CR>', {buffer = true})
