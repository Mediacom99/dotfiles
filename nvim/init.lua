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
    local uv = vim.uv
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
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.colorcolumn = "100"
vim.opt.shortmess:append("I")
vim.opt.scrolloff = 16
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true
vim.opt.pumheight = 10
vim.opt.guicursor = ""

local servers = { "lua_ls" }
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
                    insert_mappings = false,
                    direction = "vertical",
                    size = 80,
                }
            end
        },
        {
            "nvim-treesitter/nvim-treesitter",
            branch = "main",
            lazy = false,
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter").install({
                    "c", "lua", "vim", "vimdoc", "javascript", "html", "zig", "bash",
                    "markdown", "markdown_inline", "go", "gomod", "gosum",
                    "typescript", "tsx", "python", "rust", "css", "json", "yaml", "toml",
                })
                vim.api.nvim_create_autocmd("FileType", {
                    group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
                    callback = function(ev)
                        local ft = vim.bo[ev.buf].filetype
                        local lang = vim.treesitter.language.get_lang(ft) or ft
                        if pcall(vim.treesitter.start, ev.buf, lang) then
                            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        end
                    end,
                })
            end
        },
        {
            'nvim-telescope/telescope.nvim',
            version = '*',
            dependencies = { 'nvim-lua/plenary.nvim' },
            keys = {
                { '<leader>ff', function() require('telescope.builtin').find_files() end,     desc = 'Find files' },
                { '<leader>fg', function() require('telescope.builtin').live_grep() end,      desc = 'Live grep' },
                { '<leader>fb', function() require('telescope.builtin').buffers() end,        desc = 'Buffers' },
                { '<leader>fh', function() require('telescope.builtin').help_tags() end,      desc = 'Help tags' },
                { '<leader>fr', function() require('telescope.builtin').resume() end,         desc = 'Telescope resume' },
                { '<leader>fd', function() require('telescope.builtin').diagnostics() end,    desc = 'Diagnostics' },
                { 'grr',        function() require('telescope.builtin').lsp_references() end, desc = 'Find references' },
            },
            config = function()
                require('telescope').setup({})
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
            "williamboman/mason.nvim",
            dependencies = {
                "williamboman/mason-lspconfig.nvim",
            },
            config = function()
                local mason = require("mason")
                local mason_lspconf = require("mason-lspconfig")
                mason.setup()
                mason_lspconf.setup({
                    -- available servers: https://github.com/williamboman/mason-lspconfig.nvim
                    ensure_installed = servers,
                    automatic_enable = false,
                })

                -- Use table assignment syntax, not function call
                vim.lsp.config.lua_ls = {
                    cmd = { 'lua-language-server' },
                    filetypes = { 'lua' },
                    root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            workspace = {
                                checkThirdParty = false,
                                library = { vim.env.VIMRUNTIME },
                            },
                        }
                    }
                }

                vim.lsp.config.zls = {
                    cmd = { "zls" },
                    filetypes = { 'zig', 'zir' },
                    root_markers = { 'build.zig', 'zls.json', '.git' },
                    settings = {
                        zls = {
                            semantic_token = "full",
                            warn_style = true,
                        },
                    }
                }

                vim.lsp.config.clangd = {
                    cmd = {
                        'clangd',
                        '--clang-tidy',
                        '--background-index',
                        '--header-insertion=never'
                    },
                    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
                    root_markers = { 'compile_commands.json', 'compile_flags.txt', '.clangd', '.git' },
                }

                vim.lsp.config.ts_ls = {
                    cmd = { 'typescript-language-server', '--stdio' },
                    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
                    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
                    init_options = {
                        maxTsServerMemory = 4096,
                    }
                }

                vim.lsp.config.basedpyright = {
                    cmd = { 'basedpyright-langserver', '--stdio' },
                    filetypes = { 'python' },
                    root_markers = { '.git', 'pyproject.toml' },
                }

                vim.lsp.config.rust_analyzer = {
                    cmd = { 'rust-analyzer' },
                    filetypes = { 'rust' },
                    root_markers = { 'Cargo.toml', '.git' },
                }

                vim.lsp.config.elixirls = {
                    cmd = { 'elixir-ls' },
                    filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
                    root_markers = { 'mix.exs', '.git' },
                }

                vim.lsp.config.gopls = {
                    cmd = { 'gopls' },
                    filetypes = { 'go', 'gomod', 'gowork', 'gosum' },
                    root_markers = { 'go.work', 'go.mod', '.git' },
                    settings = {
                        gopls = { gofumpt = true },
                    },
                }

                vim.lsp.config.tailwindcss = {
                    cmd = { 'tailwindcss-language-server', '--stdio' },
                    filetypes = { 'html', 'css', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
                    root_markers = { 'tailwind.config.js', 'tailwind.config.ts', '.git' },
                }

                -- Enable only the servers whose binary is installed (mason's bin is on PATH by now)
                vim.lsp.enable(vim.tbl_filter(function(name)
                    return vim.fn.executable(vim.lsp.config[name].cmd[1]) == 1
                end, {
                    "gopls",
                    "clangd",
                    "lua_ls",
                    "rust_analyzer",
                    "zls",
                    "elixirls",
                    "tailwindcss",
                    "basedpyright",
                    "ts_ls",
                }))
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
            -- Loaded at startup so it replaces netrw for `nvim .` and `:e dir`
            lazy = false,
            keys = {
                { '<leader>e', function() require('nvim-tree.api').tree.toggle() end, desc = 'NvimTree toggle' },
            },
            dependencies = {
                "nvim-tree/nvim-web-devicons",
            },
            config = function()
                require("nvim-tree").setup({
                    filters = { dotfiles = false },
                })
            end,
        },
        {
            'saghen/blink.cmp',
            dependencies = { 'rafamadriz/friendly-snippets' },
            version = '1.*',
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
            event = { "BufReadPre", "BufNewFile" },
            config = function()
                -- Check that eslint_d is installed
                if vim.fn.executable('eslint_d') ~= 1 then
                    vim.notify("eslint_d not found. Install with: yarn global add eslint_d", vim.log.levels.WARN)
                    return
                end

                local lint = require("lint")

                vim.env.ESLINT_D_PPID = vim.fn.getpid()
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
                        -- Checked on every lint so it follows :cd; false forces the legacy config
                        vim.env.ESLINT_USE_FLAT_CONFIG = has_flat_config() and "true" or "false"
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
    rocks = { enabled = false },
})

-- Go: organize imports before conform formats with gopls
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("go_organize_imports", { clear = true }),
    pattern = "*.go",
    callback = function(ev)
        local client = vim.lsp.get_clients({ bufnr = ev.buf, name = "gopls" })[1]
        if not client then
            return
        end
        local params = vim.tbl_extend("force", vim.lsp.util.make_range_params(0, client.offset_encoding), {
            context = { only = { "source.organizeImports" }, diagnostics = {} },
        })
        local res = client:request_sync("textDocument/codeAction", params, 1000, ev.buf)
        for _, action in ipairs(res and res.result or {}) do
            if action.edit then
                vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
            end
        end
    end,
})

-- Lsp keybinds
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Lsp: go to declaration' })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Lsp: go to definition' })
-- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {desc = 'Lsp: go to implementation'})


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
-- Not <leader>x: it is the prefix of the Trouble keys and would wait timeoutlen
vim.keymap.set('n', '<leader>X', '<C-x>', { desc = 'Decrement number' })

vim.diagnostic.config({
    virtual_text = true,
    virtual_lines = false,
    signs = false,
    update_in_insert = false,
    float = {
        max_width = 80,
        wrap = true,
    }
})
