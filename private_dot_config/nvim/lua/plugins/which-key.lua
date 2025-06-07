return {
    { -- Useful plugin to show you pending keybinds.
        "folke/which-key.nvim",
        event = "VimEnter", -- Sets the loading event to 'VimEnter'
        config = function() -- This is the function that runs, AFTER loading
            require("which-key").setup()

            -- Document existing key chains
            local wk = require("which-key")
            wk.add({
                mode = { "n" },
                { "<leader>b", group = "De[B]ugging" },
                { "<leader>b_", hidden = true },
                { "<leader>c", group = "[C]ode" },
                { "<leader>c_", hidden = true },
                { "<leader>d", group = "[D]ocument" },
                { "<leader>d_", hidden = true },
                { "<leader>h", group = "Git [H]unk" },
                { "<leader>h_", hidden = true },
                { "<leader>l", group = "[L]sp" },
                { "<leader>l_", hidden = true },
                { "<leader>n", group = "[N]eo Tree" },
                { "<leader>n_", hidden = true },
                { "<leader>r", group = "[R]ename" },
                { "<leader>r_", hidden = true },
                { "<leader>s", group = "[S]earch" },
                { "<leader>s_", hidden = true },
            }, {
                mode = { "v" },
                { "<leader>h", group = "Git [H]unk" },
                { "<leader>h_", hidden = true },
            })
        end,
    },
}
