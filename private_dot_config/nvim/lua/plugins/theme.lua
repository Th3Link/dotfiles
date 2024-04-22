return {
    --    {
    --        "folke/tokyonight.nvim",
    --        lazy = false,
    --        priority = 1000,
    --        opts = {},
    --        init = function()
    --            -- Load the colorscheme here.
    --            -- Like many other themes, this one has different styles, and you could load
    --            -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
    --            vim.cmd.colorscheme("tokyonight-night")
    --
    --            -- You can configure highlights by doing something like:
    --            vim.cmd.hi("Comment gui=none")
    --        end,
    --    },
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },
}
