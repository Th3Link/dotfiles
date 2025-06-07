vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.g.mapleader = " "
vim.g.background = "light"

vim.opt.swapfile = false

-- Unmap hjkl in normal mode
vim.api.nvim_set_keymap("n", "h", "", { noremap = true })
vim.api.nvim_set_keymap("n", "j", "", { noremap = true })
vim.api.nvim_set_keymap("n", "k", "", { noremap = true })
vim.api.nvim_set_keymap("n", "l", "", { noremap = true })

-- Unmap hjkl in visual mode
vim.api.nvim_set_keymap("v", "h", "", { noremap = true })
vim.api.nvim_set_keymap("v", "j", "", { noremap = true })
vim.api.nvim_set_keymap("v", "k", "", { noremap = true })
vim.api.nvim_set_keymap("v", "l", "", { noremap = true })

-- Set j_ mapping
vim.api.nvim_set_keymap("n", "je", 've"0p', { noremap = true })
vim.api.nvim_set_keymap("n", "jj", 'viw"0p', { noremap = true })
vim.api.nvim_set_keymap("n", "j.", "viwp", { noremap = true })
vim.api.nvim_set_keymap("n", "J", 'dd"0P', { noremap = true, silent = true })

-- Navigate vim panes better
vim.keymap.set("n", "<c-Up>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-Down>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-Left>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-Right>", ":wincmd l<CR>")

vim.api.nvim_set_keymap("n", "<leader>bm", ":bnext<cr>", { desc = "next [B]uffer", noremap = true, silent = true })
vim.api.nvim_set_keymap(
    "n",
    "<leader>bb",
    ":bprevious<cr>",
    { desc = "previous [B]uffer", noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<leader>bd", ":bdelete<cr>", { desc = "delete [B]uffer", noremap = true, silent = true })

vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")
vim.wo.number = true

vim.opt.tabstop = 4 -- A TAB character looks like 4 spaces
vim.opt.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.opt.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.opt.shiftwidth = 4 -- Number of spaces inserted when indenting

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 400

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 400

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
