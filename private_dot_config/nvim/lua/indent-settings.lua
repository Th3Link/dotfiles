--- Set the fold options given the `expandtab` and `tabstop` params
--- @param expandtab? boolean
--- @param tabstop? integer
return function(expandtab, tabstop)
	vim.api.nvim_buf_set_option(0, 'expandtab', expandtab or false)
	vim.api.nvim_buf_set_option(0, 'shiftwidth', 0)  -- Use tabstop
	vim.api.nvim_buf_set_option(0, 'softtabstop', -1) -- Use shiftwidth
	vim.api.nvim_buf_set_option(0, 'tabstop', tabstop or 3) -- How many spaces a tab is worth
end
