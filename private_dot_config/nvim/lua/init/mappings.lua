--[[
 __  __                   _
|  \/  |                 (_)
| \  / | __ _ _ __  _ __  _ _ __   __ _ ___
| |\/| |/ _` | '_ \| '_ \| | '_ \ / _` / __|
| |  | | (_| | |_) | |_) | | | | | (_| \__ \
|_|  |_|\__,_| .__/| .__/|_|_| |_|\__, |___/
             | |   | |             __/ |
             |_|   |_|            |___/
--]]
vim.g.mapLeader = '\\'

--[[
       _           ___                         __  _
 _  __(_)_ _   ___/ (_)__ ____ ____  ___  ___ / /_(_)___
| |/ / /  ' \_/ _  / / _ `/ _ `/ _ \/ _ \(_-</ __/ / __/
|___/_/_/_/_(_)_,_/_/\_,_/\_, /_//_/\___/___/\__/_/\__/
                         /___/
--]]
vim.api.nvim_set_keymap('n', '[d', '', {callback = vim.diagnostic.goto_prev})
vim.api.nvim_set_keymap('n', ']d', '', {callback = vim.diagnostic.goto_next})
vim.api.nvim_set_keymap('n', 'gC', '', {callback = function() vim.diagnostic.reset(nil, 0) end})
vim.api.nvim_set_keymap('n', 'gK', '', {callback = vim.diagnostic.open_float})

--[[
       _         __
 _  __(_)_ _    / /__ ___
| |/ / /  ' \_ / (_-</ _ \
|___/_/_/_/_(_)_/___/ .__/
                   /_/
--]]
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(event)
		local bufnr = event.buf
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gA', '', {callback = vim.lsp.buf.rename})
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '', {callback = vim.lsp.buf.declaration})
		-- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '', {callback = vim.lsp.buf.definition})
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gh', '', {callback = vim.lsp.buf.signature_help})
		-- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '', {callback = vim.lsp.buf.implementation})
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'go', '<Cmd>LspOrganizeImports<CR>', {})
		-- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '', {callback = vim.lsp.buf.references})
		-- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gw', '', {callback = vim.lsp.buf.document_symbol})
		-- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gW', '', {callback = vim.lsp.buf.workspace_symbol})
		-- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gy', '', {callback = vim.lsp.buf.type_definition})
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '', {callback = vim.lsp.buf.hover})
		for _, mode in ipairs {'n', 'v'} do
			vim.api.nvim_buf_set_keymap(bufnr, mode, 'gq', '', {callback = vim.lsp.buf.format})
			vim.api.nvim_buf_set_keymap(bufnr, mode, 'gx', '', {callback = vim.lsp.buf.code_action})
		end
	end,
	group = 'config',
})

--[[
   __  ____
  /  |/  (_)__ ____
 / /|_/ / (_-</ __/
/_/  /_/_/___/\__/
--]]
vim.api.nvim_set_keymap('n', '<F10>', '<Cmd>Inspect<CR>', {})
vim.api.nvim_set_keymap('n', '<F11>', '', {callback = function()
	local winnr = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(winnr)

	vim.api.nvim_command 'InspectTree'
	local inspect_winnr = vim.api.nvim_get_current_win()

	vim.api.nvim_set_current_win(winnr)
	vim.api.nvim_win_set_cursor(winnr, cursor)
	vim.api.nvim_set_current_win(inspect_winnr)
end})

-- Make `p` in visual mode not overwrite the unnamed register by default. `P` now does that.
vim.api.nvim_set_keymap('v', 'p', 'P', {noremap = true})
vim.api.nvim_set_keymap('v', 'P', 'p', {noremap = true})

-- Sort selected text
vim.api.nvim_set_keymap('v', '<Leader>s', ":sort iu<CR>", {})

--[[
   ____              _
  / __/__  ___ _____(_)__  ___ _
 _\ \/ _ \/ _ `/ __/ / _ \/ _ `/
/___/ .__/\_,_/\__/_/_//_/\_, /
   /_/                   /___/
--]]

vim.api.nvim_set_keymap('n', '<Leader><C-v>', '', {callback = function()
	vim.api.nvim_set_option('paste', not vim.api.nvim_get_option 'paste')
end})

-- Reset kerning
vim.api.nvim_set_keymap('', '<Leader>rk', 'kJi<C-m><Esc>', {noremap = true})

-- Copy to clipboard
vim.keymap.set({'v', 'n'}, '<Leader>y', '"+y')
vim.api.nvim_set_keymap('n', '<Leader>Y', '"+y$', {noremap = true})

-- Paste from clipboard
vim.api.nvim_set_keymap('n', '<Leader>p', 'a<C-r>+<Esc>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>P', 'A<C-r>+<Esc>', {noremap = true})

-- Move lines visually rather than logically
vim.api.nvim_set_keymap('', '<C-j>', 'gj', {noremap = true})
vim.api.nvim_set_keymap('', '<C-k>', 'gk', {noremap = true})

-- Toggle concealing
vim.api.nvim_set_keymap('n', '<C-c>', '', {callback = function()
	vim.api.nvim_win_set_option(0, 'conceallevel',
		vim.api.nvim_win_get_option(0, 'conceallevel') < 2 and 2 or 0
	)
end})

--[[
  ____       __  _
 / __ \___  / /_(_)__  ___  ___
/ /_/ / _ \/ __/ / _ \/ _ \(_-<
\____/ .__/\__/_/\___/_//_/___/
    /_/
--]]

-- Toggle linewrap
vim.api.nvim_set_keymap('n', '<Leader>l', '', {callback = function()
	vim.api.nvim_win_set_option(0, 'wrap', not vim.api.nvim_win_get_option(0, 'wrap'))
end})

-- Toggle Spellcheck
vim.api.nvim_set_keymap('n', '<Leader>s', '', {callback = function()
	vim.api.nvim_win_set_option(0, 'spell', not vim.api.nvim_win_get_option(0, 'spell'))
end})

--[[
 _      ___         __
| | /| / (_)__  ___/ /__ _    _____
| |/ |/ / / _ \/ _  / _ \ |/|/ (_-<
|__/|__/_/_//_/\_,_/\___/__,__/___/
--]]

-- close window
vim.api.nvim_set_keymap('n', '<A-q>', '<Cmd>quit<CR>', {})

-- Location list
vim.api.nvim_set_keymap('n', '<A-w>l', '<Cmd>lwindow<CR>', {})
vim.api.nvim_set_keymap('n', '[l', '<Cmd>lprevious<CR>', {})
vim.api.nvim_set_keymap('n', ']l', '<Cmd>lnext<CR>', {})
vim.api.nvim_set_keymap('n', '[L', '<Cmd>lfirst<CR>', {})
vim.api.nvim_set_keymap('n', ']L', '<Cmd>llast<CR>', {})

-- Quickfix Window
vim.api.nvim_set_keymap('n', '<A-w>q', '<Cmd>cwindow<CR>', {})
vim.api.nvim_set_keymap('n', '[q', '<Cmd>cprevious<CR>', {})
vim.api.nvim_set_keymap('n', ']q', '<Cmd>cnext<CR>', {})
vim.api.nvim_set_keymap('n', '[Q', '<Cmd>cfirst<CR>', {})
vim.api.nvim_set_keymap('n', ']Q', '<Cmd>clast<CR>', {})

-- switch between windows, preserving size
vim.api.nvim_set_keymap('n', '<A-h>', '<C-w><Left>', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-l>', '<C-w><Right>', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-k>', '<C-w><Up>', {noremap = true})
vim.api.nvim_set_keymap('n', '<A-j>', '<C-w><Down>', {noremap = true})

-- switch between windows, maximizing them
vim.api.nvim_set_keymap('n', '<Leader><A-h>', '<C-w><Left><Cmd>vertical resize<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader><A-j>', '<C-w><Down><Cmd>horizontal resize<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader><A-k>', '<C-w><Up><Cmd>horizontal resize<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader><A-l>', '<C-w><Right><Cmd>vertical resize<CR>', {noremap = true})

-- reset split size
vim.api.nvim_set_keymap('n', '<A-0>', '<C-w>=', {noremap = true})

-- Tabs
vim.api.nvim_set_keymap('n', '[T', '<Cmd>tabfirst<CR>', {})
vim.api.nvim_set_keymap('n', '[t', ':tabprevious<CR>', {})
vim.api.nvim_set_keymap('n', ']T', '<Cmd>tablast<CR>:', {})
vim.api.nvim_set_keymap('n', ']t', ':tabnext<CR>', {})

if _G['nvim >= 0.10'] then
	vim.api.nvim_set_keymap('!a', 'DEFUALT', 'DEFAULT', {noremap = true})
	vim.api.nvim_set_keymap('!a', 'Defualt', 'Default', {noremap = true})
	vim.api.nvim_set_keymap('!a', 'defualt', 'default', {noremap = true})
else
	vim.cmd [[
		noreabbr DEFUALT DEFAULT
		noreabbr Defualt Default
		noreabbr defualt default
	]]
end
