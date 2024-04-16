--[[
           _       _              _
 _ __ ___ (_)_ __ (_)  _ ____   _(_)_ __ ___
| '_ ` _ \| | '_ \| | | '_ \ \ / / | '_ ` _ \
| | | | | | | | | | |_| | | \ V /| | | | | | |
|_| |_| |_|_|_| |_|_(_)_| |_|\_/ |_|_| |_| |_|
--]]

--[[/* Misc */]]

require('mini.ai').setup {n_lines = 1000}
require('mini.align').setup {mappings = {start = '<Leader>a', start_with_preview = '<Leader>A'}}
require('mini.comment').setup {options = {ignore_blank_line = true}}
require('mini.jump2d').setup({mappings = {start_jumping = '<Space>'}})
require('mini.misc').setup_restore_cursor()
require('mini.surround').setup {n_lines = 1000}

do --[[/* mini.files */]]
	--- @class mini.Entry
	--- @field fs_type 'file'|'directory'
	--- @field name string basename of the FS entry (including extension)
	--- @field path string the full path of an entry

	local files = require 'mini.files'
	files.setup
	{
		--- @type {[string]: fun(entry: mini.Entry): boolean}
		content = {filter = function(entry)
			return not (entry.fs_type == 'directory' and (
				entry.name == '.cache' or
				entry.name == '.git' or
				entry.name == 'node_modules'
			))
		end},

		mappings = {go_in = 'L', go_in_plus = 'l', synchronize = '<Enter>'},
		windows = {preview = true},
	}

	do -- HACK: MiniFiles doesn't play well with `:bdelete`
		local old_go_in = files.go_in
		function files.go_in()
			old_go_in()
			local entry = files.get_fs_entry() --- @type mini.Entry|nil
			if entry and entry.fs_type == 'file' then
				vim.api.nvim_buf_set_option(vim.api.nvim_win_get_buf(files.get_target_window()), 'buflisted', true)
			end
		end
	end

	--- @param close? boolean
	--- @param vertical? boolean
	--- @return fun()
	local function open_file_in_split(close, vertical)
		return function()
			local entry = files.get_fs_entry() --- @type mini.Entry|nil
			local is_file = entry and entry.fs_type == 'file'
			if is_file then
				vim.api.nvim_win_call(files.get_target_window(), function()
					vim.cmd.split {mods = {split = 'belowright', vertical = vertical}}
					files.set_target_window(vim.api.nvim_get_current_win())
				end)
			end

			files.go_in()
			if close and is_file then
				files.close()
			end
		end
	end

	--- @param chdir fun(dir: string): boolean|nil # returns `true` if it changed the tab-local directory
	--- @return fun()
	local function set_dir_to_entry(chdir)
		return function()
			local entry = files.get_fs_entry() --- @type mini.Entry|nil
			if entry == nil then return vim.notify('No FS entry selected', vim.log.levels.INFO) end
			local dir = vim.fs.dirname(entry.path)
			vim.notify(':' .. (chdir(dir) and 't' or '') .. 'cd changed to ' .. vim.inspect(dir), vim.log.levels.INFO)
		end
	end

	vim.api.nvim_create_autocmd('User', {
		pattern = 'MiniFilesBufferCreate',
		callback = function(args)
			local buf_id = args.data.buf_id

			vim.api.nvim_buf_set_keymap(buf_id, 'n', '<C-s>', '', {
				callback = open_file_in_split(true, true),
				desc = 'Open file in vertical split and close file browser',
			})

			vim.api.nvim_buf_set_keymap(buf_id, 'n', '<C-w>s', '', {
				callback = open_file_in_split(false),
				desc = 'Open file in horizontal split',
			})

			vim.api.nvim_buf_set_keymap(buf_id, 'n', '<C-w>v', '', {
				callback = open_file_in_split(false, true),
				desc = 'Open file in vertical split',
			})

			vim.api.nvim_buf_set_keymap(buf_id, 'n', '<C-x>', '', {
				callback = open_file_in_split(true),
				desc = 'Open file in horizontal split and close file browser',
			})

			vim.api.nvim_buf_set_keymap(buf_id, 'n', 'gf', '', {
				callback = set_dir_to_entry(function(dir) vim.loop.chdir(dir) end),
				desc = 'Set current directory',
			})

			vim.api.nvim_buf_set_keymap(buf_id, 'n', 'gF', '', {
				callback = set_dir_to_entry(function(dir)
					vim.cmd.tcd {args = {dir}}
					return true
				end),
				desc = 'Set the tab-local directory',
			})
		end,
	})

	vim.api.nvim_create_autocmd('User', {
		pattern = 'MiniFilesWindowOpen',
		callback = function(args) vim.api.nvim_win_set_config(args.data.win_id, {border = 'rounded'}) end,
	})

	vim.api.nvim_set_keymap('n', '<A-w>e', '', {desc = 'Focus current file in file explorer', callback = function()
		if not files.close() then
			files.open(vim.api.nvim_buf_get_name(0))
			files.reveal_cwd()
		end
	end})

	vim.api.nvim_set_keymap('n', '<A-w>E', '', {desc = 'Resume previous file exploration.', callback = function()
		return files.close() or files.open(files.get_latest_path())
	end})
end

do --[[/* mini.jump */]]
	local jump = require 'mini.jump'
	jump.setup {mappings = {repeat_jump = ''}}

	vim.api.nvim_create_autocmd('CursorHold', {callback = jump.stop_jumping, group = 'config'})
	vim.api.nvim_set_keymap('n', ',', '', {callback = function() jump.jump(nil, true, nil, vim.v.count1) end})
	vim.api.nvim_set_keymap('n', ';', '', {callback = function() jump.jump(nil, false, nil, vim.v.count1) end})
end

do --[[/* mini.splitjoin */]]

	local split_join = require 'mini.splitjoin'
	local brackets = {brackets = {'%b{}', '%b[]'}}
	split_join.setup
	{
		join = {hooks_post = {split_join.gen_hook.del_trailing_separator {brackets}}},
		split = {hooks_post = {split_join.gen_hook.add_trailing_separator {brackets}}},
	}
end

do --[[/* mini.trailspace */]]
	local trailspace = require 'mini.trailspace'
	vim.api.nvim_create_autocmd('BufWritePre',
	{
		callback = function(tbl)
			if not vim.api.nvim_buf_get_option(tbl.buf, 'binary') and
				vim.api.nvim_buf_get_option(tbl.buf, 'filetype') ~= 'diff'
			then
				trailspace.trim_last_lines()
			end
		end,
		group = 'config',
	})
end
