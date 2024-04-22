return {
    "mfussenegger/nvim-dap",
    dependencies = {
        {
            "leoluz/nvim-dap-go",
        },
        {
            "rcarriga/nvim-dap-ui",
            dependencies = {
                "nvim-neotest/nvim-nio",
            },
        },
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        vim.keymap.set("n", "<leader>bt", dap.toggle_breakpoint, { desc = "[T]oggle Breakpoint" })
        vim.keymap.set("n", "<leader>bc", dap.continue, { desc = "[C]ontinue" })

        dapui.setup()
        require("dap-go").setup()
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        dap.adapters.gdb = {
            type = "executable",
            command = "gdb",
            args = { "-i", "dap" },
        }

        dap.configurations.c = {
            {
                name = "Launch",
                type = "gdb",
                request = "launch",
                program = "${workspaceFolder}/a.out",
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = false,
            },
        }

        dap.configurations.cpp = {
            {
                name = "Launch",
                type = "gdb",
                request = "launch",
                program = "a.out",
                cwd = "${workspaceFolder}",
                stopAtBeginningOfMainSubprogram = false,
            },
        }
    end,
}
