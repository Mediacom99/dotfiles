-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setting mapleader and vim.opt
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.smartcase = true
vim.opt.incsearch = true
vim.opt.colorcolumn = "100"
vim.opt.shortmess:append("I")
vim.opt.scrolloff = 16
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true


-- Setup lazy.nvim
require("lazy").setup({
    spec = {
        -- Gruber Darker theme
        {
            "blazkowolf/gruber-darker.nvim",
            lazy = false,
            priority = 1000,
            opts = {
                bold = true,
                italic = {
                    strings = false,
                    comments = false,
                    operators = false,
                    folds = false,
                }
            },
            config = function()
                vim.cmd.colorscheme("gruber-darker")
            end
        },
        -- {
        --     "rose-pine/neovim",
        --     lazy = false,
        --     priority = 1000,
        --     name = "rose-pine",
        --     config = function()
        --         local config = require("rose-pine")
        --         config.setup({
        --             styles = {
        --                 italic = false,
        --             },
        --         })
        --         vim.cmd("colorscheme rose-pine")
        --     end
        -- },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function ()
                local configs = require("nvim-treesitter.configs")
                configs.setup({
                    ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html", "zig"},
                    sync_install = false,
                    highlight = { enable = true },
                    indent = { enable = true },
                })
            end
        },
        {
            'nvim-telescope/telescope.nvim', tag = '0.1.8',
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
                local servers = { "lua_ls", "zls", "bashls", "clangd" }
                mason.setup()
                mason_lspconf.setup({
                    -- available servers: https://github.com/williamboman/mason-lspconfig.nvim
                    ensure_installed = servers,
                    automatic_installation = true,
                })

                lspconf.lua_ls.setup({
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = {'vim', 'os'}
                            }
                        }
                    }
                })

                -- zls config json schema: 
                -- https://raw.githubusercontent.com/zigtools/zls/refs/tags/0.13.0/schema.json
                lspconf.zls.setup({
                    zig_lib_path = "/home/mediacom/zig013/lib",
                    zig_exe_path = "/home/mediacom/zig013",
                })

                lspconf.bashls.setup({})
                lspconf.clangd.setup({})
            end
        },
        {
            "hrsh7th/nvim-cmp",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-cmdline",
                "hrsh7th/cmp-nvim-lua",
            },
            config = function()
                local configs = require("cmp")
                configs.setup({
                    sources = configs.config.sources({
                        { name = "nvim_lsp" },
                        { name = "buffer" },
                        { name = "nvim_lua" },
                        { name = "cmdline" },
                    }),
                    windows = {
                        completion = configs.config.window.bordered(),
                        documentation = configs.config.window.bordered(),
                    },
                    mapping = configs.mapping.preset.insert({
                            ['<Tab>'] = configs.mapping.confirm({ select = true }),
                        }),
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
            "nvim-tree/nvim-tree.lua",
              version = "*",
              lazy = true,
              dependencies = {
                "nvim-tree/nvim-web-devicons",
              },
              config = function()
                local nvimtree = require("nvim-tree")
                nvimtree.setup({
                    filters = {
                        dotfiles = false,
                    },
                })
              end,
        }


    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
    rocks = { enabled = true },
})

-- Keymaps
-- TODO move this into telescope config
local builtin = require('telescope.builtin')
local nvimtree = require('nvim-tree.api')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>e', nvimtree.tree.toggle, {desc = 'NvimTree toggle'})

-- Custom commands
-- Open telescope find files command at startup
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- Only open telescope if no files were specified
        if #vim.fn.argv() == 0 then
            require("telescope.builtin").find_files()
        end
    end,
})
