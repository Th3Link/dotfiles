return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    opts = {
        filesystem = {
            filtered_items = {
                visible = true,
                --hide_dotfiles = false,
                --show_hidden_count = true,
                --hide_gitignored = true,
                --hide_by_name = {
                --   ".git",
                --    ".DS_Store",
                --    "thumbs.db",
                --},
                --never_show = {},
            },
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function(_, opts)
        vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", {})
        vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
        require("neo-tree").setup(opts)
        vim.api.nvim_create_autocmd("VimEnter", {
            command = "set nornu nonu | Neotree toggle",
        })
        vim.api.nvim_create_autocmd("BufEnter", {
            command = "set rnu nu",
        })
    end,
}
