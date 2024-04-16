--[[
 __  __ _             _____             __ _
|  \/  (_)           / ____|           / _(_)
| \  / |_ ___  ___  | |     ___  _ __ | |_ _  __ _
| |\/| | / __|/ __| | |    / _ \| '_ \|  _| |/ _` |
| |  | | \__ \ (__  | |___| (_) | | | | | | | (_| |
|_|  |_|_|___/\___|  \_____\___/|_| |_|_| |_|\__, |
                                              __/ |
                                             |___/
--]]

vim.api.nvim_set_option('background', 'dark')              -- Use a dark background
vim.api.nvim_set_option_value('breakindent', true, {})     -- Preserve tabs when wrapping lines.
vim.opt.completeopt = {'menuone', 'noinsert', 'noselect'}  -- Completion visual settings
vim.api.nvim_set_option_value('concealcursor', 'nc', {})   -- Don't unconceal in normal or command mode
vim.api.nvim_set_option_value('cursorline', true, {})      -- Highlight current line
vim.opt.diffopt:append 'linematch:60'                      -- Highlight inline diffs
vim.opt.fillchars = {fold = ' ', msgsep = '▔'}             -- Set folds to not trail dots
vim.api.nvim_set_option_value('foldexpr', 'v:lua.vim.treesitter.foldexpr()', {}) -- Use treesitter for folds
vim.api.nvim_set_option_value('foldmethod', 'expr', {})  -- Set folding to occur from a marker
vim.api.nvim_set_option_value('foldtext', 'v:lua.NeatFoldText()', {}) -- Set text of folds
vim.api.nvim_set_option_value('grepprg', 'rg --vimgrep', {}) -- Use ripgrep instead of grep.
vim.api.nvim_set_option('guicursor', '')                   -- Remove vertical cursor from insert mode
vim.api.nvim_set_option('ignorecase', true)                -- Case insensitive search by default
vim.api.nvim_set_option('inccommand', 'split')             -- Show regular expression previews in a split
vim.api.nvim_set_option('laststatus', 3)                   -- Only show a statusline at the bottom of the screen
vim.api.nvim_set_option('lazyredraw', true)                -- Redraw screen less often
vim.api.nvim_set_option_value('linebreak', true, {})       -- Break lines at whole words
vim.api.nvim_set_option('mouse', '')                       -- Disable the mouse
vim.api.nvim_set_option_value('number', true, {})          -- Show the current line number
vim.api.nvim_set_option_value('relativenumber', true, {})  -- Line numbers relative to current line
vim.api.nvim_set_option_value('shiftwidth', 0, {})         -- Use tabstop
vim.api.nvim_set_option('showmode', false)                 -- Don't show the mode name under the statusline
vim.api.nvim_set_option('showtabline', 0)                  -- Don't show the tabline until tabline plugins load
vim.api.nvim_set_option('smartcase', true)                 -- Case sensitive when a capital is provided
vim.api.nvim_set_option_value('smartindent', true, {})     -- More intelligent 'autoindent' preset
vim.api.nvim_set_option_value('softtabstop', -1, {})       -- Use shiftwidth
vim.api.nvim_set_option('splitbelow', true)                -- Splits open below
vim.api.nvim_set_option('splitright', true)                -- Splits open to the right
vim.api.nvim_set_option_value('spell', true, {})           -- Check spelling
vim.api.nvim_set_option_value('tabstop', 3, {})            -- How many spaces a tab is worth
vim.api.nvim_set_option('termguicolors', true)             -- Set color mode
vim.api.nvim_set_option('undodir', vim.fn.stdpath('state') .. '/undodir') -- Put undo history in the state dir
vim.api.nvim_set_option_value('undofile', true, {})        -- Persist undo history
vim.opt.viewoptions = {'cursor', 'folds'}                  -- Save cursor position and folds in `:mkview`
vim.api.nvim_set_option('visualbell', true)                -- Disable beeping
vim.opt.wildmode = {'longest:full', 'full'}                -- Command completion mode
vim.api.nvim_set_option('wildignorecase', true)            -- Ignore case for command completions
vim.opt.wildignore = {'*.bak', '*.cache', '*/.git/**/*', '*.min.*', '*/node_modules/**/*', '*.pyc', '*.swp'}

if _G['nvim >= 0.10'] then
	vim.api.nvim_set_option_value('smoothscroll', true, {})
end

-- Providers
vim.g.loaded_node_provder = false -- disable javascript
vim.g.loaded_perl_provider = false -- disable Perl
vim.g.loaded_python3_provider = false -- disable Python 3
vim.g.loaded_ruby_provider = false -- disable Ruby

--[[
   ___       __                                         __
  / _ |__ __/ /____  _______  __ _  __ _  ___ ____  ___/ /__
 / __ / // / __/ _ \/ __/ _ \/  ' \/  ' \/ _ `/ _ \/ _  (_-<
/_/ |_\_,_/\__/\___/\__/\___/_/_/_/_/_/_/\_,_/_//_/\_,_/___/
--]]
local augroup = vim.api.nvim_create_augroup('config', {clear = false})

--- Reset my indent guide settings
vim.api.nvim_create_autocmd({'BufWinEnter', 'BufWritePost', 'InsertLeave'},
{
	callback = function()
		vim.api.nvim_set_option_value('list', true, {})
		vim.opt.listchars = {nbsp = '␣', tab = '│ ', trail = '•'}
		vim.api.nvim_set_option_value('showbreak', '└ ', {})
	end,
	group = augroup,
})

--- Sync syntax when not editing text
vim.api.nvim_create_autocmd('CursorHold',
{
	callback = function(event)
		if vim.api.nvim_buf_get_option(event.buf, 'syntax') ~= '' then
			vim.api.nvim_command 'syntax sync fromstart'
		end

		if vim.lsp.semantic_tokens then
			vim.lsp.semantic_tokens.force_refresh(event.buf)
		end
	end,
	group = augroup,
})

vim.api.nvim_create_autocmd('BufEnter', {
	callback = function(event)
		local textwidth = tostring(vim.api.nvim_buf_get_option(event.buf, 'textwidth'))
		vim.api.nvim_set_option_value('colorcolumn', textwidth, {win = vim.api.nvim_get_current_win()})
	end,
	group = augroup,
})

vim.api.nvim_create_autocmd({'FocusGained', 'VimResume'}, {command = 'checktime', group = augroup})

vim.api.nvim_create_autocmd('OptionSet',
{
	callback = function(event)
		local buf = event.buf == 0 and vim.api.nvim_get_current_buf() or event.buf
		local textwidth = tostring(vim.api.nvim_buf_get_option(buf, 'textwidth'))
		for _, winnr in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(winnr) == buf then
				vim.api.nvim_set_option_value('colorcolumn', textwidth, {win = winnr})
			end
		end
	end,
	group = augroup,
	pattern = 'textwidth',
})

--- Highlight yanks
vim.api.nvim_create_autocmd('TextYankPost',
{
	callback = function() vim.highlight.on_yank() end,
	group = augroup,
})

if vim.fn.has 'wsl' == 1 then
	vim.api.nvim_create_autocmd('TextYankPost',
	{
		command = [[call system('clip.exe ',@")]],
		group = augroup,
	})
end

--[[
  _____                              __
 / ___/__  __ _  __ _  ___ ____  ___/ /__
/ /__/ _ \/  ' \/  ' \/ _ `/ _ \/ _  (_-<
\___/\___/_/_/_/_/_/_/\_,_/_//_/\_,_/___/
--]]
-- Space-Tab Conversion
vim.api.nvim_create_user_command(
	'SpacesToTabs',
	function(tbl)
		vim.api.nvim_buf_set_option(0, 'expandtab', false)
		local previous_tabstop = vim.api.nvim_buf_get_option(0, 'tabstop')
		vim.api.nvim_buf_set_option(0, 'tabstop', tonumber(tbl.args))
		vim.api.nvim_command 'retab!'
		vim.api.nvim_buf_set_option(0, 'tabstop', previous_tabstop)
	end,
	{force = true, nargs = 1}
)

vim.api.nvim_create_user_command(
	'TabsToSpaces',
	function(tbl)
		vim.api.nvim_buf_set_option(0, 'expandtab', true)
		local previous_tabstop = vim.api.nvim_buf_get_option(0, 'tabstop')
		vim.api.nvim_buf_set_option(0, 'tabstop', tonumber(tbl.args))
		vim.api.nvim_command 'retab'
		vim.api.nvim_buf_set_option(0, 'tabstop', previous_tabstop)
	end,
	{force = true, nargs = 1}
)

-- Vim LSP stuff
vim.api.nvim_create_user_command(
	'LspOrganizeImports',
	'lua vim.lsp.buf.code_action{source = {organizeImports = true}}',
	{force = true}
)

-- Fat fingering
vim.api.nvim_create_user_command('W', 'w', {})
vim.api.nvim_create_user_command('Wq', 'wq', {})
vim.api.nvim_create_user_command('Wqa', 'wqa', {})
vim.api.nvim_create_user_command('X', 'x', {})
vim.api.nvim_create_user_command('Xa', 'xa', {})

--[[
   ____              __  _
  / __/_ _____  ____/ /_(_)__  ___  ___
 / _// // / _ \/ __/ __/ / _ \/ _ \(_-<
/_/  \_,_/_//_/\__/\__/_/\___/_//_/___/
--]]

--- Benchmark some `fn`, printing the average time it takes to run given the number of `loops`.
--- @param fn fun(i: integer) the code to benchmark
--- @param loops? integer the number of times to run the code. Higher number = more accurate averate
function Bench(fn, loops)
	loops = loops or 100000

	local now = vim.loop.hrtime --- @type fun(): integer
	local total = 0

	for i = 1, loops do
		local start = now()
		fn(i)
		total = total + (now() - start)
	end

	print(total / loops)
end

local columns = vim.api.nvim_get_option 'columns' --- @type integer
vim.api.nvim_create_autocmd('VimResized', {
	callback = function()
		columns = vim.api.nvim_get_option 'columns'
	end,
	group = augroup,
})

--- @return string fold_text a neat template for the summary of what is on a fold
function NeatFoldText()
	--- @type string
	local line_text = vim.api.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldstart, true)[1]

	-- NOTE: 10 is the magic number for the base width of the template text.
	--        5 is the magic number for the replacement text.
	if #line_text + 10 > columns then
		local remove = math.ceil(bit.rshift(columns - #line_text, 1) + 10 + 5)
		local middle = bit.rshift(#line_text, 1)
		line_text = line_text:sub(1, middle - remove) .. ' […] ' .. line_text:sub(middle + remove)
	end

	return ('   %-6d%s'):format(vim.v.foldend - vim.v.foldstart + 1, line_text)
end
