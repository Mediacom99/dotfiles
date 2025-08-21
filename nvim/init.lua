-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setting mapleader and vim.opt
vim.o.swapfile = false
vim.o.signcolumn = "yes"
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.colorcolumn = "100"
vim.opt.shortmess:append("I")
vim.opt.scrolloff = 16
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.opt.pumheight = 10
vim.o.background = 'dark'
-- vim.o.winborder = "rounded"

local servers = { "lua_ls", "bashls", "fish_lsp" }
local lazy = require("lazy")
lazy.setup({
    spec = {
        -- {
        --     "blazkowolf/gruber-darker.nvim",
        --     lazy = false,
        --     priority = 1000,
        --     opts = {
        --         bold = true,
        --         italic = {
        --             strings = false,
        --             comments = false,
        --             operators = false,
        --             folds = false,
        --         }
        --     },
        -- },
        {
            "catppuccin/nvim",
            name = "catppuccin",
            priority = 1000,
            config = function()
                vim.cmd.colorscheme("catppuccin-mocha")
            end
        },
        -- {
        --     'neanias/everforest-nvim',
        --     version = false,
        --     lazy = false,
        --     priority = 1000,
        --     config = function()
        --         require("everforest").setup({
        --             background = "hard"
        --         })
        --         vim.cmd([[colorscheme everforest]])
        --         vim.o.background = "dark"
        --     end,
        -- },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                local configs = require("nvim-treesitter.configs")
                configs.setup({
                    ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html", "zig", "bash" },
                    sync_install = false,
                    highlight = { enable = true },
                    indent = { enable = true },
                })
            end
        },
        {
            'nvim-telescope/telescope.nvim',
            tag = '0.1.8',
            dependencies = { 'nvim-lua/plenary.nvim' },
            config = function()
                require('telescope').setup({
                    pickers = {
                        find_files = {
                            hidden = false,
                        }
                    },
                    extensions = {
                        file_browser = {
                            hijack_netrw = true,
                        },
                    },
                })
            end
        },
        {
            'windwp/nvim-autopairs',
            event = "InsertEnter",
            config = true,
            opts = {
                check_ts = true,
            }
        },
        {
            "neovim/nvim-lspconfig",
            dependencies = {
                "williamboman/mason.nvim",
                "williamboman/mason-lspconfig.nvim",
            },
            config = function()
                local lspconf = require("lspconfig")
                local mason = require("mason")
                local mason_lspconf = require("mason-lspconfig")
                local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
                mason.setup()
                mason_lspconf.setup({
                    -- available servers: https://github.com/williamboman/mason-lspconfig.nvim
                    ensure_installed = servers,
                    automatic_installation = true,
                    automatic_enable = false,
                })

                lspconf.fish_lsp.setup({})
                lspconf.lua_ls.setup({
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { 'vim', 'os' }
                            }
                        }
                    }
                }, { capabilities = blink_capabilities })
                lspconf.zls.setup({
                    capabilities = blink_capabilities,
                    cmd = { "/home/mediacom/zls/zig-out/bin/zls" },
                    settings = {
                        zls = {
                            semantic_token = "full;",
                            warn_style = "true",
                        },
                    }
                })
                -- lspconf.clangd.setup({capabilities = blink_capabilities})
                lspconf.basedpyright.setup({ capabilities = blink_capabilities })
                lspconf.ts_ls.setup({
                    init_options = {
                        tsserver = {
                            maxTsServerMemory = 8196,
                        },
                    },
                })
            end
        },
        {
            "folke/which-key.nvim",
            event = "VeryLazy",
            opts = {},
            keys = {
                {
                    "<leader>?",
                    function()
                        require("which-key").show({ global = false })
                    end,
                    desc = "Buffer Local Keymaps (which-key)",
                },
            },
        },
        {
            'saghen/blink.cmp',
            dependencies = { 'rafamadriz/friendly-snippets' },
            version = '1.*',
            ---@module 'blink.cmp'
            opts = {
                -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
                -- 'super-tab' for mappings similar to vscode (tab to accept)
                -- 'enter' for enter to accept
                -- 'none' for no mappings
                --
                -- All presets have the following mappings:
                -- C-space: Open menu or open docs if already open
                -- C-n/C-p or Up/Down: Select next/previous item
                -- C-e: Hide menu
                -- C-k: Toggle signature help (if signature.enabled = true)
                --
                -- See :h blink-cmp-config-keymap for defining your own keymap
                keymap = { preset = 'enter' },
                appearance = {
                    nerd_font_variant = 'mono'
                },
                completion = { documentation = { auto_show = true } },
                sources = {
                    default = { 'lsp', 'path', 'snippets', 'buffer' },
                },
                signature = { enabled = true, window = { show_documentation = false } },
                fuzzy = { implementation = "rust" }
            },
            opts_extend = { "sources.default" }
        },
        -- {
        --     "NeogitOrg/neogit",
        --     dependencies = {
        --         "nvim-lua/plenary.nvim",         -- required
        --         "sindrets/diffview.nvim",        -- optional - Diff integration
        --         -- Only one of these is needed.
        --         "nvim-telescope/telescope.nvim", -- optional
        --     },
        -- },
        {
            'stevearc/conform.nvim',
            opts = {},
            config = function()
                local conform = require("conform")
                conform.setup({
                    lua = { "stylua" },
                    zig = { "zigfmt" },
                    format_on_save = {
                        timeout_ms = 500,
                        lsp_format = "fallback",
                    },
                })
            end
        },
        {
            "mikavilpas/yazi.nvim",
            event = "VeryLazy",
            dependencies = {
                { "nvim-lua/plenary.nvim", lazy = true },
            },
            keys = {
                -- 👇 in this section, choose your own keymappings!
                {
                    "<leader>-",
                    mode = { "n", "v" },
                    "<cmd>Yazi<cr>",
                    desc = "Open yazi at the current file",
                },
                {
                    -- Open in the current working directory
                    "<leader>cw",
                    "<cmd>Yazi cwd<cr>",
                    desc = "Open the file manager in nvim's working directory",
                },
                {
                    "<c-up>",
                    "<cmd>Yazi toggle<cr>",
                    desc = "Resume the last yazi session",
                },
            },
            opts = {
                -- if you want to open yazi instead of netrw, see below for more info
                open_for_directories = false,
                keymaps = {
                    show_help = "<f1>",
                },
            },
            -- 👇 if you use `open_for_directories=true`, this is recommended
            init = function()
                -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
                -- vim.g.loaded_netrw = 1
                vim.g.loaded_netrwPlugin = 1
            end,
        },
        {
            'mrcjkb/rustaceanvim',
            version = '^6',
            lazy = false,
        },

        {
            "folke/trouble.nvim",
            opts = {}, -- for default options, refer to the configuration section for custom setup.
            cmd = "Trouble",
            keys = {
                {
                    "<leader>xx",
                    "<cmd>Trouble diagnostics toggle<cr>",
                    desc = "Diagnostics (Trouble)",
                },
                {
                    "<leader>xX",
                    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                    desc = "Buffer Diagnostics (Trouble)",
                },
                {
                    "<leader>cs",
                    "<cmd>Trouble symbols toggle focus=false<cr>",
                    desc = "Symbols (Trouble)",
                },
                {
                    "<leader>cl",
                    "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                    desc = "LSP Definitions / references / ... (Trouble)",
                },
                {
                    "<leader>xL",
                    "<cmd>Trouble loclist toggle<cr>",
                    desc = "Location List (Trouble)",
                },
                {
                    "<leader>xQ",
                    "<cmd>Trouble qflist toggle<cr>",
                    desc = "Quickfix List (Trouble)",
                },
            },
        }
    },
    install = { colorscheme = { "catppuccin-mocha" } },
})

-- Keymaps
-- TODO move this into telescope config
local telescope = require('telescope.builtin')
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Telescope find files' }, opts)
vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = 'Telescope live grep' }, opts)
vim.keymap.set('n', '<leader>fb', telescope.buffers, { desc = 'Telescope buffers' }, opts)
vim.keymap.set('n', '<leader>fh', telescope.help_tags, { desc = 'Telescope help tags' }, opts)

-- Lsp keybinds
vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, { desc = 'Lsp: go to declaration' }, opts)
vim.keymap.set('n', 'gD', vim.lsp.buf.definition, { desc = 'Telescope: go to definition' }, opts)
-- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {desc = 'Lsp: go to implementation'})
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' }, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' }, opts)

vim.keymap.set('n', 'grr', telescope.lsp_references, {
    desc = 'Find references',
}, opts)

vim.diagnostic.config({
    virtual_text = true,
    virtual_lines = false,
    signs = false,
    update_in_insert = true,
})

-- Open telescope find files command at startup
-- vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function()
--         -- Only open telescope if no files were specified
--         if #vim.fn.argv() == 0 then
--             require("telescope.builtin").find_files()
--         end
--     end,
-- })
