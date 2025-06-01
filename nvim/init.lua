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
vim.opt.pumheight = 10


local servers = { "lua_ls", "bashls", "clangd" }
local lazy = require("lazy")
lazy.setup({
    spec = {
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
        --   'neanias/everforest-nvim',
        --   version = false,
        --   lazy = false,
        --   priority = 1000,
        --   config = function()
        --     require("everforest").setup({
        --         background = "hard"
        --     })
        --     vim.cmd([[colorscheme everforest]])
        --     vim.o.background = "dark"
        --   end,
        -- },
        {
            'akinsho/toggleterm.nvim',
            version = "*",
            config = function ()
               require("toggleterm").setup{
                    open_mapping = [[<C-p>]],
                    direction = "vertical",
                    size = 80,
                }
            end
        },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function ()
                local configs = require("nvim-treesitter.configs")
                configs.setup({
                    ensure_installed = { "c", "lua", "vim", "vimdoc", "javascript", "html", "zig", "bash"},
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
                local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
                mason.setup()
                mason_lspconf.setup({
                    -- available servers: https://github.com/williamboman/mason-lspconfig.nvim
                    ensure_installed = servers,
                    automatic_installation = true,
                    automatic_enable = false,
                })

                lspconf.lua_ls.setup({
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = {'vim', 'os'}
                            }
                        }
                    }
                }, {capabilities = blink_capabilities})
                lspconf.zls.setup({
                    capabilities = blink_capabilities,
                    cmd = {"/home/mediacom/zls/zig-out/bin/zls"},
                    settings = {
                        zls = {
                            semantic_token = "full;",
                            warn_style = "true",
                        },
                    }
                })
                -- lspconf.clangd.setup({capabilities = blink_capabilities})
                lspconf.basedpyright.setup({capabilities = blink_capabilities})
            end
        },
        -- {
        --     "hrsh7th/nvim-cmp",
        --     dependencies = {
        --         "hrsh7th/cmp-nvim-lsp",
        --         "hrsh7th/cmp-buffer",
        --         "hrsh7th/cmp-path",
        --         "hrsh7th/cmp-cmdline",
        --         "hrsh7th/cmp-nvim-lua",
        --     },
        --     config = function()
        --         local configs = require("cmp")
        --         configs.setup({
        --             sources = configs.config.sources({
        --                 { name = "nvim_lsp" },
        --                 { name = "buffer" },
        --                 { name = "nvim_lua" },
        --                 -- { name = "cmdline" },
        --             }),
        --             windows = {
        --                 completion = configs.config.window.bordered(),
        --                 documentation = configs.config.window.bordered(),
        --             },
        --             mapping = configs.mapping.preset.insert({
        --                     ['<CR>'] = configs.mapping.confirm({ select = true }),
        --                 }),
        --         })
        --         configs.setup.cmdline({'/', '?'}, {
        --             mapping = configs.mapping.preset.cmdline(),
        --             sources = {
        --                 { name = 'buffer' }
        --             }
        --         })
        --         for _, value in ipairs(servers) do
        --             require('lspconfig')[value].setup {
        --                 capabilities = require("cmp_nvim_lsp").default_capabilities()
        --             }
        --         end
        --     end
        -- },
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
        },
        {
          'saghen/blink.cmp',
          dependencies = { 'rafamadriz/friendly-snippets' },
          version = '1.*',
          ---@module 'blink.cmp'
          ---@type blink.cmp.Config
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
            signature = { enabled = true, window = { show_documentation = false} },
            fuzzy = { implementation = "rust" }
          },
          opts_extend = { "sources.default" }
        },
        -- {
        --     -- This plugin reconstructs completion item and 
        --     -- applies treesitter highlight queries 
        --     -- to produce variable-size highlight ranges.
        --     "xzbdmw/colorful-menu.nvim",
        --     config = function ()
        --         require("colorful-menu").setup({})
        --     end
        -- }

    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    -- install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
    rocks = { enabled = true },
})

-- Keymaps
-- TODO move this into telescope config
local telescope = require('telescope.builtin')
local nvimtree = require('nvim-tree.api')
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>ff', telescope.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', telescope.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', telescope.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>e', nvimtree.tree.toggle, {desc = 'NvimTree toggle'})

-- Lsp keybinds
vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, { desc = 'Lsp: go to declaration' })
vim.keymap.set('n', 'gD', vim.lsp.buf.definition, {desc = 'Telescope: go to definition'})
-- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {desc = 'Lsp: go to implementation'})
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {desc = 'Go to previous diagnostic'})
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {desc = 'Go to next diagnostic'})

vim.keymap.set('n', 'grr', telescope.lsp_references, {
    desc = 'Find references'
})

-- Remap key to exit terminal mode
vim.keymap.set('t', '<C-x>', [[<C-\><C-n>]], { noremap = true, silent = true })

-- Normal mode: Alt+h/j/k/l to move between splits
vim.keymap.set('n', '<A-h>', '<C-w>h')
vim.keymap.set('n', '<A-j>', '<C-w>j')
vim.keymap.set('n', '<A-k>', '<C-w>k')
vim.keymap.set('n', '<A-l>', '<C-w>l')

-- Insert mode: Alt+h/j/k/l to move between splits
vim.keymap.set('i', '<A-h>', '<C-\\><C-N><C-w>h')
vim.keymap.set('i', '<A-j>', '<C-\\><C-N><C-w>j')
vim.keymap.set('i', '<A-k>', '<C-\\><C-N><C-w>k')
vim.keymap.set('i', '<A-l>', '<C-\\><C-N><C-w>l')

-- Terminal mode: Alt+h/j/k/l to move between splits
vim.keymap.set('t', '<A-h>', '<C-\\><C-N><C-w>h')
vim.keymap.set('t', '<A-j>', '<C-\\><C-N><C-w>j')
vim.keymap.set('t', '<A-k>', '<C-\\><C-N><C-w>k')
vim.keymap.set('t', '<A-l>', '<C-\\><C-N><C-w>l')

vim.diagnostic.config({
    virtual_text = true,
    virtual_lines = false,
    signs = false,
    update_in_insert = true,
})

-- Custom commands
-- Open telescope find files command at startup
-- vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function()
--         -- Only open telescope if no files were specified
--         if #vim.fn.argv() == 0 then
--             require("telescope.builtin").find_files()
--         end
--     end,
-- })
