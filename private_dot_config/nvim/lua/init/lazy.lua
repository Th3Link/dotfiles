--[[
 _                              _
| | __ _ _____   _   _ ____   _(_)_ __ ___
| |/ _` |_  / | | | | '_ \ \ / / | '_ ` _ \
| | (_| |/ /| |_| |_| | | \ V /| | | | | | |
|_|\__,_/___|\__, (_)_| |_|\_/ |_|_| |_| |_|
             |___/
--]]

--[[/* Vars */]]

local not_man = vim.g.man ~= true

--- Return a wrapper function which loads the `plugin`'s configuration file
--- @param plugin string
--- @return fun()
local function req(plugin)
	return function() require('plugin.' .. plugin) end
end

--[[/* Install lazy.nvim */]]

local install_path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(install_path) then
	vim.fn.system
	{
		'git', 'clone', '--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git', '--branch=stable',
		install_path
	}
end

--[[/* Load plugins */]]

vim.opt.rtp:prepend(install_path)
require('lazy').setup(
	{
		{'folke/lazy.nvim', tag = 'stable'},

		--[[
			___                                     _
		  / _ \_______  ___ ________ ___ _  __ _  (_)__  ___ _
		 / ___/ __/ _ \/ _ `/ __/ _ `/  ' \/  ' \/ / _ \/ _ `/
		/_/  /_/  \___/\_, /_/  \_,_/_/_/_/_/_/_/_/_//_/\_, /
						  /___/                            /___/
		--]]

		--[[/* Completion / Language Servers / Linting / Snippets */]]

		{'hrsh7th/nvim-cmp',
			config = function()
				--- @return boolean # `true` if the cursor is on a word
				local function cursor_on_word()
					local col = vim.api.nvim_win_get_cursor(0)[2]
					return col ~= 0 and vim.api.nvim_get_current_line():sub(col, col):find '%s' == nil
				end

				local cmp = require 'cmp'
				local kind = require('cmp.types').lsp.CompletionItemKind --- @type lsp.CompletionItemKind
				local snippy = require 'snippy'

				local SOURCES =
				{
					buffer = '',
					latex_symbols = '󱔁',
					nvim_lsp = '',
					nvim_lua = '󰢱',
					path = '',
					snippy = '',
					spell = '󰓆',
					['vim-dadbod-completion'] = '',
				}

				cmp.setup(
				{
					formatting =
					{
						format = function(entry, vim_item)
							vim_item.menu = SOURCES[entry.source.name]
							return vim_item
						end,
					},

					mapping =
					{
						['<C-b>'] = cmp.mapping.scroll_docs(-20),
						['<C-f>'] = cmp.mapping.scroll_docs(20),
						['<C-Space>'] = cmp.mapping.confirm {behavior = cmp.ConfirmBehavior.Insert, select = true},

						--- @param fallback fun()
						['<Tab>'] = cmp.mapping(function(fallback)
							if not cmp.select_next_item() then
								if cursor_on_word() then
									cmp.complete()
								elseif snippy.can_expand_or_advance() then
									snippy.expand_or_advance()
								else
									fallback()
								end
							end
						end, {'i', 's'}),

						--- @param fallback fun()
						['<S-Tab>'] = cmp.mapping(function(fallback)
							if not cmp.select_prev_item() then
								if cursor_on_word() then
									cmp.complete()
								elseif snippy.can_jump(-1) then
									snippy.previous()
								else
									fallback()
								end
							end
						end, {'i', 's'}),
					},

					snippet = {expand = function(args) snippy.expand_snippet(args.body) end},

					sources = cmp.config.sources(
						{
							{name = 'nvim_lsp', entry_filter = function(entry) return kind[entry:get_kind()] ~= 'Text' end},
							{name = 'snippy'}
						},
						{{name = 'nvim_lua'}, {name = 'vim-dadbod-completion'}},
						{{name = 'path'}},
						{{name = 'spell'}, {name = 'buffer'}},
						{{name = 'latex_symbols', max_item_count = 10}}
					),

					window =
					{
						completion = {border = 'rounded', winhighlight = 'CursorLine:PmenuSel,Search:None'},
						documentation = {border = 'rounded', winhighlight = ''},
					},
				})
			end,
			dependencies =
			{
				'f3fora/cmp-spell',
				'hrsh7th/cmp-path',
				'hrsh7th/cmp-buffer',
				'hrsh7th/cmp-nvim-lsp',
				'hrsh7th/cmp-nvim-lua',
				'kdheepak/cmp-latex-symbols',
				{'kristijanhusak/vim-dadbod-completion', dependencies = 'tpope/vim-dadbod'},
				{'dcampos/cmp-snippy', dependencies = {'dcampos/nvim-snippy', dependencies = 'honza/vim-snippets'}},
			},
			event = 'InsertEnter',
		},

		-- LSP
		{'neovim/nvim-lspconfig', cond = not_man, config = req 'lsp.lspconfig'},
		{'ray-x/lsp_signature.nvim',
			cond = not_man and not _G['nvim >= 0.10'],
			init = function()
				vim.api.nvim_create_autocmd('LspAttach', {
					callback = function(event)
						require('lsp_signature').on_attach(
							{floating_window = false, hint_scheme = '@text.literal', hint_prefix = ''},
							event.buf
						)
					end,
					group = 'config',
				})
			end,
			lazy = true,
		},

		--[[/* Outlining*/]]

		{'folke/todo-comments.nvim',
			cond = not_man,
			dependencies = 'nvim-lua/plenary.nvim',
			opts =
			{
				highlight = {comments_only = false, keyword = 'bg'},
				keywords =
				{
					FIX = {icon = ''},
					NOTE = {icon = ''},
					PERF = {icon = '󰓅'},
					TEST = {icon = ''},
					TODO = {icon = '󰦕'},
					WARN = {icon = ''},
				},
			},
			event = 'FileType',
		},
		{'folke/trouble.nvim',
			cond = not_man,
			dependencies = 'nvim-web-devicons',
			keys =
			{
				{'<A-w>D', '<Cmd>TroubleToggle workspace_diagnostics<CR>', desc = 'Toggle trouble.nvim workspace diagnostics', mode = 'n'},
				{']D',
					function() require('trouble').next {skip_groups = true, jump = true} end,
					desc = 'Jump to the next Trouble entry',
					mode = 'n',
				},
				{'[D',
					function() require('trouble').previous {skip_groups = true, jump = true} end,
					desc = 'Jump to the previous Trouble entry',
					mode = 'n',
				},
				{'<A-w>t', '<Cmd>TodoTrouble<CR>', desc = 'Toggle trouble.nvim todos using todo-comments.nvim', mode = 'n'},
			},
			opts = function(_, o)
				o.auto_preview = false
			end,
		},
		{'stevearc/aerial.nvim',
			dependencies = {'nvim-treesitter', 'nvim-web-devicons'},
			keys = {{'<A-w>s', '<Cmd>AerialToggle<CR>', desc = 'Toggle aerial.nvim', mode = 'n'}},
			opts = function(_, o)
				o.backends = {'lsp', 'treesitter', 'man', 'markdown'}
				o.filter_kind = false
				o.icons =
				{
					Array         = '󱡠',
					Boolean       = '󰨙',
					Class         = '󰆧',
					Constant      = '󰏿',
					Constructor   = '',
					Enum          = '',
					EnumMember    = '',
					Event         = '',
					Field         = '',
					File          = '󰈙',
					Function      = '󰊕',
					Interface     = '',
					Key           = '󰌋',
					Method        = '󰊕',
					Module        = '',
					Namespace     = '󰦮',
					Null          = '󰟢',
					Number        = '󰎠',
					Object        = '',
					Operator      = '󰆕',
					Package       = '',
					Property      = '',
					String        = '',
					Struct        = '󰆼',
					TypeParameter = '󰗴',
					Variable      = '󰀫',
					ArrayCollapsed         = '󱡠 ',
					BooleanCollapsed       = '󰨙',
					ClassCollapsed         = '󰆧 ',
					ConstantCollapsed      = '󰏿',
					ConstructorCollapsed   = ' ',
					EnumCollapsed          = ' ',
					EnumMemberCollapsed    = ' ',
					EventCollapsed         = ' ',
					FieldCollapsed         = ' ',
					FileCollapsed          = '󰈙 ',
					FunctionCollapsed      = '󰊕 ',
					InterfaceCollapsed     = ' ',
					KeyCollapsed           = '󰌋 ',
					MethodCollapsed        = '󰊕 ',
					ModuleCollapsed        = ' ',
					NamespaceCollapsed     = '󰦮 ',
					NullCollapsed          = '󰟢',
					NumberCollapsed        = '󰎠',
					ObjectCollapsed        = ' ',
					OperatorCollapsed      = '󰆕 ',
					PackageCollapsed       = ' ',
					PropertyCollapsed      = ' ',
					StringCollapsed        = '',
					StructCollapsed        = '󰆼 ',
					TypeParameterCollapsed = '󰗴',
					VariableCollapsed      = '󰀫',
				}
				o.layout =
				{
					default_direction = 'right',
					max_width = {40, 0.25}
				}
				o.guides =
				{
					last_item = '└─ ',
					mid_item = '├─ ',
					nested_top = '│  ',
					whitespace = '   ',
				}
				o.keymaps =
				{
					['?'] = false,
					['[['] = 'actions.prev',
					['[]'] = 'actions.prev_up',
					[']['] = 'actions.next_up',
					[']]'] = 'actions.next',
				}
				o.show_guides = true
				o.update_events = 'CursorHold,CursorHoldI,InsertLeave'
			end,
		},
		{'mbbill/undotree',
			cond = not_man,
			config = function()
				vim.api.nvim_set_var('undotree_TreeNodeShape', '●')
				vim.api.nvim_set_var('undotree_TreeReturnShape', '╲')
				vim.api.nvim_set_var('undotree_TreeSplitShape', '╱')
				vim.api.nvim_set_var('undotree_TreeVertShape', '│')
			end,
			keys = {{'<A-w>u', '<Cmd>UndotreeToggle<CR>', desc = 'Toggle Undotree', mode = 'n'}},
		},

		--[[/* Specific Language Support, Syntax Highlighting, Formatting */]]

		{'norcalli/nvim-colorizer.lua', cond = not_man, config = true, keys = {{
			'<Leader>c', '<Cmd>ColorizerToggle<CR>', mode = 'n',
		}}},

		{'nvim-treesitter/nvim-treesitter',
			build = ':TSUpdate',
			cond = not_man,
			config = function()
				require('nvim-treesitter.configs').setup
				{
					auto_install = true,
					highlight = {additional_vim_regex_highlighting = false, enable = true},
					indent = {enable = false},
					playground = {enable = true},
				}
			end,
		},

		{'amadeus/vim-xml', cond = not_man, ft = 'xml'},
		{'aklt/plantuml-syntax',
			cond = not_man,
			config = function()
				vim.api.nvim_set_var('plantuml_executable_script', '/usr/bin/plantuml')
			end,
			ft = 'plantuml',
		},
		{'ionide/Ionide-vim', cond = not_man, ft = {'fsharp', 'fsharp_project'}},
		{'jlcrochet/vim-razor', cond = not_man, ft = 'razor'},
		{'leafo/moonscript-vim', cond = not_man, ft = 'moon'},
		{'mboughaba/i3config.vim', cond = not_man, ft = 'i3config'},
		{'MTDL9/vim-log-highlighting', cond = not_man, ft = 'log'},
		{'wgwoods/vim-systemd-syntax', cond = not_man, ft = 'systemd'},

		--[[
			____             _      __  ____         __
		  / __/__  ___ ____(_)__ _/ / / __/__ ___ _/ /___ _________ ___
		 _\ \/ _ \/ -_) __/ / _ `/ / / _// -_) _ `/ __/ // / __/ -_|_-<
		/___/ .__/\__/\__/_/\_,_/_/ /_/  \__/\_,_/\__/\_,_/_/  \__/___/
			/_/
		--]]
		{'echasnovski/mini.nvim', config = req 'mini'},
		{'kevinhwang91/nvim-bqf', ft = 'qf'},
		{'NMAC427/guess-indent.nvim', cond = not_man, config = true, event = 'BufReadPre'},
		{'nvim-telescope/telescope.nvim',
			cmd = 'Telescope',
			cond = not_man,
			config = function()
				local previewers = require 'telescope.previewers'
				local telescope = require 'telescope'

				local cursor_theme = require('telescope.themes').get_cursor {layout_config =
				{
					height = 0.5,
					width = 0.9,
				}}

				local cursor_theme_no_jump = vim.deepcopy(cursor_theme)
				cursor_theme_no_jump.jump_type = 'never'

				telescope.setup
				{
					defaults =
					{
						file_ignore_patterns = {'^%.git/'},
						file_previewer = previewers.cat.new,
						grep_previewer = previewers.vimgrep.new,
						history = false,
						qflist_previewer = previewers.qflist.new,

						layout_config =
						{
							center = {prompt_position = 'bottom'},
							cursor = {height = 0.5, width = 0.9},
							horizontal = {height = 0.95, width = 0.9},
							vertical = {height = 0.95, width = 0.9},
						},
						layout_strategy = 'flex',
						multi_icon = '󰄵 ',
						prompt_prefix = ' ',
						selection_caret = ' ',
					},

					extensions = {["ui-select"] = {cursor_theme}},
					pickers =
					{
						find_files = {hidden = true},
						lsp_definitions = cursor_theme,
						lsp_implementations = cursor_theme,
						lsp_references = cursor_theme_no_jump,
						lsp_document_symbols = cursor_theme_no_jump,
						lsp_workspace_symbols = cursor_theme_no_jump,
						spell_suggest = cursor_theme,
					},
				}
			end,
			init = function()
				vim.api.nvim_create_autocmd('LspAttach', {
					callback = function(event)
						local bufnr = event.buf
						vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>Telescope lsp_definitions<CR>', {})
						vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<Cmd>Telescope lsp_implementations<CR>', {})
						vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<Cmd>Telescope lsp_references<CR>', {})
						vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gw', '<Cmd>Telescope lsp_document_symbols<CR>', {})
						vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gW', '<Cmd>Telescope lsp_workspace_symbols<CR>', {})
						vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gy', '<Cmd>Telescope lsp_type_definitions<CR>', {})
					end,
					group = 'config',
				})
			end,
			keys =
			{
				{'<A-f>', '<Cmd>Telescope find_files<CR>', desc = 'Fuzzy find file', mode = 'n'},
				{'<C-f>', '<C-w>s<A-f>', desc = 'Fuzzy find file in new split', mode = 'n', remap = true},
				{'<Leader>f', '<Cmd>Telescope<CR>', desc = 'Fuzzy find telescope pickers', mode = 'n'},
				{'<Leader>F', '<Cmd>Telescope resume<CR>', desc = 'Resume last telescope search', mode = 'n'},
				{'z=', '<Cmd>Telescope spell_suggest<CR>', desc = 'Fuzzy find spelling suggestion', mode = 'n'},
			},
		},
		{'nvim-telescope/telescope-ui-select.nvim',
			dependencies = 'telescope.nvim',
			init = function()
				--- Lazy loads telescope on first run
				--- @diagnostic disable-next-line:duplicate-set-field
				function vim.ui.select(...)
					require('telescope').load_extension 'ui-select'
					vim.ui.select(...)
				end
			end,
			lazy = true,
		},

		--[[/* Movement */]]

		{'machakann/vim-swap', cond = not_man, keys = {
			{'gs', '<Plug>(swap-interactive)', desc = 'Enter vim-swap mode', mode = {'n', 'x'}},
		}},

		--[[/* Text Manipulation */]]

		--[[/* UI */]]

		{'dstein64/vim-win',
			cond = not_man,
			commit = '00a31b44f9388927102dcd96606e236f13681a33',
			keys = {{'<Leader>w', '<Plug>WinWin', desc = 'Enter winmode', mode = 'n'}},
		},
		{'Iron-E/nvim-libmodal', cond = not_man, lazy = true},
		{'Iron-E/nvim-bufmode',
			cond = not_man,
			dependencies = 'nvim-libmodal',
			keys = {{'<Leader>b', desc = 'Enter bufmode', mode = 'n'}},
			opts = function(_, o)
				o.barbar = true
			end,
		},
		{'Iron-E/nvim-tabmode', cond = not_man, dependencies = 'nvim-libmodal', keys = {{
			'<Leader><Tab>', desc = 'Enter tabmode', mode = 'n',
		}}},
		{'kristijanhusak/vim-dadbod-ui',
			cond = not_man,
			config = function()
				vim.api.nvim_set_var('db_ui_execute_on_save', false)
				vim.api.nvim_set_var('db_ui_save_location', vim.fn.stdpath('data') .. '/db_ui')
				vim.api.nvim_set_var('db_ui_show_database_icon', true)
				vim.api.nvim_set_var('db_ui_use_nerd_fonts', true)

				vim.api.nvim_create_autocmd('FileType', {
					callback = function(event)
						vim.api.nvim_buf_set_keymap(event.buf, 'n', '<Leader>q', '<Plug>(DBUI_ExecuteQuery)', {})
						vim.api.nvim_buf_set_keymap(event.buf, 'n', '<Leader>S', '<Plug>(DBUI_SaveQuery)', {})
						vim.api.nvim_buf_set_keymap(event.buf, 'v', '<Leader>q', '<Plug>(DBUI_ExecuteQuery)', {})
					end,
					group = 'config',
					pattern = {'mysql', 'plsql', 'sql'},
				})
			end,
			dependencies = 'tpope/vim-dadbod',
			keys = {{'<A-w>d', '<Cmd>DBUIToggle<CR>', desc = 'Toggle the DBUI', mode = 'n'}},
			ft = {'mysql', 'plsql', 'sql'},
		},
		{'lewis6991/gitsigns.nvim',
			cond = not_man,
			config = function()
				require('gitsigns').setup {trouble = false}

				vim.api.nvim_set_keymap('n', '[c', '<Cmd>Gitsigns prev_hunk<CR>', {})
				vim.api.nvim_set_keymap('n', ']c', '<Cmd>Gitsigns next_hunk<CR>', {})
				vim.api.nvim_set_keymap('n', '<Leader>hs', '<Cmd>Gitsigns stage_hunk<CR>', {})
				vim.api.nvim_set_keymap('n', '<Leader>hu', '<Cmd>Gitsigns undo_stage_hunk<CR>', {})
			end,
			dependencies = 'nvim-lua/plenary.nvim',
			event = 'FileType',
		},
		{'lukas-reineke/indent-blankline.nvim',
			cond = not_man,
			config = function()
				require('indent_blankline').setup {show_trailing_blankline_indent = false}

				-- HACK: see lukas-reineke/indent-blankline.nvim#449
				local opts = {noremap = true, silent = true}
				for _, keymap in pairs {'za', 'zA', 'zc', 'zC', 'zo', 'zm', 'zM', 'zO', 'zr', 'zR', 'zv', 'zx', 'zX'} do
					vim.api.nvim_set_keymap('n', keymap,  keymap .. '<Cmd>IndentBlanklineRefresh<CR>', opts)
				end
			end,
		},
		{'nvim-tree/nvim-web-devicons', lazy = true},
		{'rebelot/heirline.nvim',
			config = req 'heirline',
			dependencies =
			{
				'gitsigns.nvim',
				{'linrongbin16/lsp-progress.nvim', opts = {spinner = {"⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽", "⣾"}}},
				'nvim-web-devicons',
			},
			event = 'UIEnter',
		},
		{'romgrk/barbar.nvim',
			cond = not_man,
			dependencies = {'gitsigns.nvim', 'nvim-web-devicons'},
			dev = true,
			init = function(barbar)
				vim.g.barbar_auto_setup = false -- disable auto-setup

				--- @param bufnr integer
				--- @return boolean
				local function filter(bufnr)
					return vim.api.nvim_buf_get_option(bufnr, 'buflisted')
				end

				vim.api.nvim_create_autocmd({'BufNewFile', 'BufReadPost', 'SessionLoadPost', 'TabEnter'}, {
					callback = function()
						if #vim.tbl_filter(filter, vim.api.nvim_list_bufs()) > 1 then
							require('lazy.core.loader').load(barbar, {cmd = 'Lazy load'})
							return true -- delete autocmd
						end
					end,
					group = 'config',
				})
			end,
			keys =
			{
				{'[B', '<Cmd>BufferFirst<CR>', desc = 'Go to the first buffer', mode = 'n'},
				{'[b', ':BufferPrevious<CR>', desc = 'Go to the previous buffer', mode = 'n'},
				{']B', '<Cmd>BufferLast<CR>', desc = 'Go to the last buffer', mode = 'n'},
				{']b', ':BufferNext<CR>', desc = 'Go to the next buffer', mode = 'n'},
			},
			lazy = true,
			opts = function(_, o)
				o.animation = false
				o.auto_hide = true
				o.clickable = false
				o.focus_on_close = 'left'
				o.highlight_alternate = true
				o.icons =
				{
					button = false,
					current =
					{
						diagnostics = {{enabled = false}, {enabled = false}},
						gitsigns = {added = {enabled = false}, changed = {enabled = false}, deleted = {enabled = false}},
					},
					diagnostics = {{enabled = true, icon = ''}, {enabled = true, icon = ''}},
					gitsigns = {added = {enabled = true}, changed = {enabled = true}, deleted = {enabled = true}},
					modified = {button = false},
					pinned = {button = '', filename = true},
					preset = 'slanted',
				}
				o.maximum_padding = math.huge
			end,
		},
		{'tversteeg/registers.nvim',
			cond = not_man,
			keys =
			{
				{'"', desc = 'View the registers', mode = {'n', 'x'}},
				{'<C-r>', desc = 'View the registers', mode = 'i'},
			},
			opts = function(_, o)
				o.window = {border = 'rounded'}
			end,
		},

		--[[
		 ________
		/_  __/ /  ___ __ _  ___ ___
		 / / / _ \/ -_)  ' \/ -_|_-<
		/_/ /_//_/\__/_/_/_/\__/___/
		--]]
		{'Iron-E/nvim-highlite',
			config = function()
				local allow_list = {__index = function() return false end}
				require('highlite').setup {terminal_colors = false, generate =
				{
					plugins =
					{
						nvim =
						{
							leap = false,
							lspsaga = false,
							nvim_tree = false,
							packer = false,
							sniprun = false,
							symbols_outline = false,
						},

						vim = setmetatable({swap = true, undotree = true}, allow_list),
					},
					syntax = setmetatable(
						{i3config = true, man = true, plantuml = true, razor = true, xml = true},
						allow_list
					),
				}}

				vim.api.nvim_command 'colorscheme highlite-custom'
			end,
			priority = math.huge,
		},
	},
	{
		dev = {fallback = true, path = '~/Programming', patterns = {'Iron-E'}},
		install = {colorscheme = {'highlite', 'habamax'}},
		performance = {rtp = {disabled_plugins =
		{
			'gzip',
			'netrwPlugin',
			'rplugin',
			'tarPlugin',
			'tohtml',
			'tutor',
			'zipPlugin',
		}}},
		ui = {border = 'rounded'},
	}
)
