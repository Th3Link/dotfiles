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
        window = {
            mappings = {
                ["h"] = { "show_help", nowait = false, config = { title = "help", prefix_key = "" } },
            },
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function(_, opts)
        vim.keymap.set("n", "<leader>nn", ":Neo[t]ree filesystem reveal left<CR>", {})
        vim.keymap.set("n", "<leader>nf", ":Neotree buffers reveal [f]loat<CR>", {})
        require("neo-tree").setup(opts)
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                if vim.fn.argc() == 0 then
                    vim.cmd("set nornu nonu | Neotree toggle")
                end
            end,
            --command = "set nornu nonu | Neotree toggle",
            --command = "Neotree toggle",
        })
        vim.api.nvim_create_autocmd("BufEnter", {
            command = "set nu",
        })
    end,
}
