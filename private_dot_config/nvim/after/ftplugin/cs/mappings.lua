-- Clear out carriage returns from the file, since Microsoft likes to put them there.
vim.keymap.set('n', '<Leader>gC', '<Cmd>%s/[\x0D]//g<CR>')
