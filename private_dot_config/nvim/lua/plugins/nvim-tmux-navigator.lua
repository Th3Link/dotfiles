return {
    {
        "alexghergh/nvim-tmux-navigation",
        config = function()
            local nvim_tmux_nav = require("nvim-tmux-navigation")

            nvim_tmux_nav.setup({
                disable_when_zoomed = true, -- defaults to false
            })

            vim.keymap.set("n", "<A-Left>", nvim_tmux_nav.NvimTmuxNavigateLeft)
            vim.keymap.set("n", "<A-Right>", nvim_tmux_nav.NvimTmuxNavigateDown)
            vim.keymap.set("n", "<A-Up>", nvim_tmux_nav.NvimTmuxNavigateUp)
            vim.keymap.set("n", "<A-Down>", nvim_tmux_nav.NvimTmuxNavigateRight)
            vim.keymap.set("n", "<A-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
            vim.keymap.set("n", "<A-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
        end,
    },
    --{
    --  "swaits/zellij-nav.nvim",
    --  lazy = true,
    --  event = "VeryLazy",
    --  keys = {
    --    { "<a-n>", "<cmd>ZellijNavigateLeft<cr>",  { silent = true, desc = "navigate left"  } },
    --    { "<a-r>", "<cmd>ZellijNavigateDown<cr>",  { silent = true, desc = "navigate down"  } },
    --    { "<a-t>", "<cmd>ZellijNavigateUp<cr>",    { silent = true, desc = "navigate up"    } },
    --    { "<a-d>", "<cmd>ZellijNavigateRight<cr>", { silent = true, desc = "navigate right" } },
    --  },
    --  opts = {},
    --}
}
