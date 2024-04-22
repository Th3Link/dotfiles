return {
    "nvim-lualine/lualine.nvim",
    config = function()
        require("lualine").setup({
            options = {
                -- theme = "tokyonight",
                theme = "catppuccin-mocha",
                sections = {
                    lualine_a = {
                        file = 1,
                    },
                },
            },
        })
    end,
}
