--[[/* Imports */]]

local lspconfig  = require 'lspconfig'

--[[/* UI */]]

vim.cmd [[
	sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
	sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=
	sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=
	sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=
]]

--- Configuration for `nvim_open_win`
local FLOAT_CONFIG = {border = 'rounded'}

--- Event handlers
local HANDLERS =
{
	["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, FLOAT_CONFIG),
	["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, FLOAT_CONFIG),
}

if _G['nvim >= 0.10'] then
	vim.api.nvim_create_autocmd('LspAttach', {
		callback = function(ev)
			if vim.lsp.get_client_by_id(ev.data.client_id).server_capabilities.inlayHintProvider then
				vim.lsp.inlay_hint(ev.buf, true)
				vim.api.nvim_buf_set_keymap(ev.buf, 'n', '<C-c>', '', {callback = function() vim.lsp.inlay_hint(0) end})
			end
		end,
		group = 'config',
	})
end

vim.diagnostic.config
{
	float = FLOAT_CONFIG,
	severity_sort = true,
	virtual_text = {prefix = ' ', source = 'if_many', spacing = 1},
}

require('lspconfig.ui.windows').default_options = FLOAT_CONFIG

--[[/* Config */]]

do -- disable lsp watcher. Too slow on linux
	local watchfiles = require 'vim.lsp._watchfiles'
	watchfiles._watchfunc = function() return function() end end
end

-- Do not log the LSP
vim.lsp.set_log_level(vim.lsp.log_levels.OFF)

-- Omnisharp exclusion pattterns
local omnisharp_exclusion_patterns =
{
	'**/node_modules/**/*',
	'**/bin/**/*',
	'**/obj/**/*',
	'/tmp/**/*'
}

--- @param lsp string
--- @param config? table
local function setup(lsp, config)
	if config == nil then
		config = {}
	end

	config.handlers = HANDLERS
	lspconfig[lsp].setup(config)
end

setup 'bashls'
setup 'cssls'
setup 'cssmodules_ls'
setup 'emmet_ls'
setup 'tailwindcss'
setup 'tsserver'
setup 'yamlls'

setup('gopls',
{ -- {{{
	--- @param client lsp.Client
	on_attach = function(client)
		if not client.server_capabilities.semanticTokensProvider then
			local semantic = vim.tbl_get(client, 'config', 'capabilities', 'textDocument', 'semanticTokens')
			if semantic then
				vim.notify_once(
					client.name .. ' supports semantic tokens but did not report it. Implementing workaround',
					vim.log.levels.INFO
				)

				client.server_capabilities.semanticTokensProvider =
				{
					full = true,
					legend = {tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes},
					range = true,
				}
			end
		end
	end,
	settings = {gopls = {semanticTokens = true}}
}) -- }}}

setup('html',
{ -- {{{
	cmd = {"vscode-html-languageserver", "--stdio"}
}) -- }}}

setup('jdtls',
{ -- {{{
	root_dir = lspconfig.util.root_pattern('.git', 'pom.xml', 'build.xml'),
	init_options =
	{
		jvm_args = {['java.format.settings.url'] = vim.fn.stdpath('config')..'/eclipse-formatter.xml'},
		workspace = vim.fn.stdpath('cache')..'/java-workspaces',
	},
}) -- }}}

setup('jsonls',
{ -- {{{
	cmd = {'vscode-json-languageserver', '--stdio'}
}) -- }}}

setup('lua_ls',
{ -- {{{
	before_init = function(_, config)
		local lua_ls_workspace_library = {}

		for _, path in ipairs(vim.api.nvim_get_runtime_file('', true)) do
			lua_ls_workspace_library[path] = true
		end

		local lazy_path = vim.fs.find('lazy', {path = vim.fn.stdpath 'data', type = 'directory'})[1] .. '/'
		for path, path_type in vim.fs.dir(lazy_path) do
			if path_type == 'directory' then
				lua_ls_workspace_library[lazy_path .. path] = true
			end
		end

		config.settings.Lua.workspace = {library = lua_ls_workspace_library}
	end,
	cmd = {'lua-language-server', '-E', '-W'},
	settings = {Lua =
	{
		diagnostics = {globals = {'vim'}},
		hint = {enable = true},
		runtime =
		{
			path = vim.split(package.path, ';', {plain = true, trimempty = true}),
			pathStrict = true,
			version = 'LuaJIT',
		},
		telemetry = {enable = false},
	}},
}) -- }}}

setup('omnisharp',
{ -- {{{
	cmd = {'/usr/bin/omnisharp', '--languageserver', '--hostPID', tostring(vim.loop.os_getpid())},
	init_options =
	{
		FileOptions =
		{
			ExcludeSearchPatterns = omnisharp_exclusion_patterns,
			SystemExcludeSearchPatterns = omnisharp_exclusion_patterns,
		},
		FormattingOptions = {EnableEditorConfigSupport = true},
		ImplementTypeOptions =
		{
			InsertionBehavior = 'WithOtherMembersOfTheSameKind',
			PropertyGenerationBehavior = 'PreferAutoProperties',
		},
		RenameOptions =
		{
			RenameInComments = true,
			RenameInStrings  = true,
			RenameOverloads  = true,
		},
		RoslynExtensionsOptions =
		{
			EnableAnalyzersSupport = true,
			EnableDecompilationSupport = true,
		},
	},
	enable_import_completion = true,
	enable_roslyn_analyzers = true,
	log_level = 2,

	--- BUG: OmniSharp/omnisharp-roslyn#2483
	--- @param client lsp.Client
	on_attach = function(client)
		--- @param list string[]
		local function isnake(list)
			for i, v in ipairs(list) do
				list[i] = v:gsub('%s*[- ]%s*', "_")
				if list[i] ~= v then
					vim.notify_once(
						client.name ..
							' supports semantic tokens but did they are improperly formatted. Implementing workaround',
						vim.log.levels.INFO
					)
				end
			end
		end

		local legend = client.server_capabilities.semanticTokensProvider.legend
		isnake(legend.tokenModifiers)
		isnake(legend.tokenTypes)
	end,
}) -- }}}

setup('rust_analyzer',
{ -- {{{
	settings = {['rust-analyzer'] =
	{
		checkOnSave = {extraArgs = {"--target-dir", "/tmp/rust-analyzer-check"}},
		diagnostics = {disabled = {'inactive-code'}},
	}},
}) -- }}}

setup('sqlls',
{ -- {{{
	cmd = {'sql-language-server', 'up', '--method', 'stdio'},
	filetypes = {'mysql', 'plsql', 'sql'},
}) -- }}}
