vim.api.nvim_buf_set_keymap(0, 'n', '][', '', {callback = function()
	require('ts_utils').goto_sibling('section', 'next')
end})

vim.api.nvim_buf_set_keymap(0, 'n', '[]', '', {callback = function()
	require('ts_utils').goto_sibling('section', 'previous')
end})
