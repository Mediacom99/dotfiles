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

-- Local custom functions

-- Automatically set flat config if present in current folder
local function has_flat_config()
    local uv = vim.loop
    local cwd = uv.cwd()

    local flat_config_patterns = {
        "eslint.config.js",
        "eslint.config.cjs",
        "eslint.config.mjs",
        "eslint.config.ts",
        "eslint.config.mts",
        "eslint.config.cts"
    }

    for _, pattern in ipairs(flat_config_patterns) do
        local filepath = cwd .. "/" .. pattern
        local stat = uv.fs_stat(filepath)
        if stat and stat.type == "file" then
            return true
        end
    end
    return false
end

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
vim.opt.guicursor = ""

-- Set colorscheme to default
vim.cmd.colorscheme('default')


local servers = { "lua_ls", "bashls", "clangd" }
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
            config = function()
                require("toggleterm").setup {
                    open_mapping = [[<C-p>]],
                    direction = "vertical",
                    size = 80,
                }
            end
        },
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

                vim.lsp.config("lua_ls", {
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { 'vim', 'os' }
                            }
                        }
                    }
                }, { capabilities = blink_capabilities })
                vim.lsp.config("rust-analyzer", { capabilities = blink_capabilities })
                vim.lsp.config("zls", {
                    capabilities = blink_capabilities,
                    cmd = { "/home/mediacom/zls/zig-out/bin/zls" },
                    settings = {
                        zls = {
                            semantic_token = "full;",
                            warn_style = "true",
                        },
                    }
                })
                vim.lsp.config("clangd", {capabilities = blink_capabilities} )
                vim.lsp.config("basedpyright", { capabilities = blink_capabilities })
                vim.lsp.config("ts_ls", {
                    capabilities = blink_capabilities,
                    init_options = {
                        maxTsServerMemory = 4096,
                    }
                })
                vim.lsp.config("tailwindcss",{ capabilities = blink_capabilities })
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
                signature = { enabled = true, window = { show_documentation = false } },
                fuzzy = { implementation = "rust" }
            },
            opts_extend = { "sources.default" }
        },
        {
            "mfussenegger/nvim-lint",
            lazy = true,
            event = { "BufReadPre", "BufNewFile" },
            ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
            config = function()
                -- TODO: use project local linter and prettier
                local lint = require("lint")

                -- Configure eslint_d to use project-local version
                lint.linters.eslint_d.cmd = function()
                    local local_eslint = vim.fn.fnamemodify('./node_modules/.bin/eslint_d', ':p')
                    if vim.fn.executable(local_eslint) == 1 then
                        return local_eslint
                    end
                    return 'eslint_d'
                end
                vim.env.ESLINT_D_PPID = vim.fn.getpid()
                -- Force legacy config by setting false
                vim.env.ESLINT_USE_FLAT_CONFIG = has_flat_config() and "true" or
                    "false"
                lint.linters_by_ft = {
                    javascript = { "eslint_d" },
                    typescript = { "eslint_d" },
                    javascriptreact = { "eslint_d" },
                    typescriptreact = { "eslint_d" },
                }
                local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
                vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
                    group = lint_augroup,
                    callback = function()
                        lint.try_lint()
                    end,
                })
            end,
        },
        {
            "stevearc/conform.nvim",
            event = { "BufWritePre" },
            cmd = { "ConformInfo" },
            keys = {
                {
                    -- Customize or remove this keymap to your liking
                    "<leader>F",
                    function()
                        require("conform").format({ async = true })
                    end,
                    mode = "",
                    desc = "Format buffer",
                },
            },
            opts = {
                -- Define your formatters
                formatters_by_ft = {
                    lua = { "stylua" },
                    javascript = { "prettierd", "prettier", stop_after_first = true },
                    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                    typescript = { "prettierd", "prettier", stop_after_first = true },
                    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                },
                -- Set default options
                default_format_opts = {
                    lsp_format = "fallback",
                },
                -- Set up format-on-save
                format_on_save = { timeout_ms = 500 },
                -- Customize formatters
                formatters = {
                    shfmt = {
                        prepend_args = { "-i", "2" },
                    },
                },
            },
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
vim.keymap.set('n', '<leader>e', nvimtree.tree.toggle, { desc = 'NvimTree toggle' })

-- Lsp keybinds
vim.keymap.set('n', 'gd', vim.lsp.buf.declaration, { desc = 'Lsp: go to declaration' })
vim.keymap.set('n', 'gD', vim.lsp.buf.definition, { desc = 'Telescope: go to definition' })
-- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {desc = 'Lsp: go to implementation'})
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })

vim.keymap.set('n', 'grr', telescope.lsp_references, {
    desc = 'Find references'
})
vim.keymap.set('n', '<leader>fr', telescope.resume, { desc = 'Telescope resume' }, opts)

vim.keymap.set('n', '<leader>L', vim.diagnostic.open_float, { desc = 'Open diagnostic floating window' })
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

-- Remap increment/decrement to different keys
vim.keymap.set('n', '<leader>a', '<C-a>', { desc = 'Increment number' })
vim.keymap.set('n', '<leader>x', '<C-x>', { desc = 'Decrement number' })

vim.diagnostic.config({
    virtual_text = true,
    virtual_lines = false,
    signs = false,
    update_in_insert = true,
    float = {
        max_width = 80,
        wrap = true,
    }
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
