-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- OPTIONS
local o = vim.o
o.termguicolors = true
o.laststatus = 3
o.showmode = false
o.splitkeep = 'screen'
o.cursorline = true
o.cursorlineopt = 'number'
o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2
o.ignorecase = true
o.smartcase = true
o.number = true
o.relativenumber = true
o.numberwidth = 2
o.ruler = false
o.signcolumn = 'yes'
o.splitbelow = true
o.splitright = true
o.timeoutlen = 1000
o.undofile = true
o.updatetime = 250
o.swapfile = false
o.backup = false
o.wrap = false

vim.opt.fillchars = { eob = ' ' }

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- MAPPINGS
local map = vim.keymap.set

local function system_open()
  local path = vim.fn.expand '%:p'
  vim.fn.jobstart({ 'open', '-R', path }, { detach = true })
end
map('n', '<leader>of', system_open, { desc = '[O]pen in [F]inder' })
map('n', '<C-u>', '<C-u>zz')
map('n', '<C-d>', '<C-d>zz')
map({ 'n', 'x' }, 'gy', '"+y', { desc = 'Copy to system clipboard' })
map({ 'n', 'x' }, 'gY', '"+Y', { desc = 'Copy line to system clipboard' })
map('n', 'gp', '"+p', { desc = 'Paste from system clipboard' })
map('x', 'gp', '"+P', { desc = 'Paste from system clipboard' })
map({ 'n', 'v' }, '<leader>d', '"_d', { desc = 'Delete without yanking' })
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
map('n', ';w', ':w<CR>')

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Theme
vim.cmd 'syntax enable'
vim.g.dracula_colorterm = 0
vim.cmd 'colorscheme dracula_pro'

-- PLUGINS
require('lazy').setup {
  checker = { enabled = true },
  spec = {
    -- Fuzzy Finder: Telescope (useful for all projects)
    {
      'nvim-telescope/telescope.nvim',
      event = 'VimEnter',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
      },
      config = function()
        require('telescope').setup {
          defaults = {
            sorting_strategy = 'ascending',
            layout_config = { horizontal = { prompt_position = 'top' } },
            mappings = { n = { ['q'] = require('telescope.actions').close } },
            file_ignore_patterns = {
              'node_modules',
              '.git/',
              '.cache/',
              'vendor/',
              'dist/',
              'build/',
              'target/',
              '.idea/',
              '.vscode/',
              '%.lock',
            },
          },
          pickers = {
            find_files = { hidden = true, follow = true, no_ignore = true },
            live_grep = {
              additional_args = function()
                return { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' }
              end,
            },
          },
          extensions = {
            ['ui-select'] = {
              require('telescope.themes').get_dropdown {},
            },
          },
        }
        require('telescope').load_extension 'ui-select'

        local builtin = require 'telescope.builtin'
        vim.keymap.set('n', '<leader><leader>', builtin.find_files, { desc = '[F]ind [F]iles' })
        vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = '[F]ind by [G]rep' })
        vim.keymap.set('n', 'g/', builtin.current_buffer_fuzzy_find, { desc = 'Fuzzy find' })
      end,
    },

    -- Best file explorer ever
    {
      'stevearc/oil.nvim',
      lazy = false,
      config = function()
        local detail = false
        require('oil').setup {
          default_file_explorer = false,
          delete_to_trash = true,
          keymaps = {
            ['gd'] = {
              desc = 'Toggle file detail view',
              callback = function()
                detail = not detail
                if detail then
                  require('oil').set_columns { 'permissions', 'size', 'mtime' }
                end
              end,
            },
          },
        }
        vim.keymap.set('n', '<leader>.', function()
          require('oil').open(nil, {
            preview = {
              split = 'belowright',
            },
          })
        end, { desc = 'File explorer' })
      end,
    },

    -- Git
    {
      'lewis6991/gitsigns.nvim',
      opts = {
        signs = {
          add = { text = '▎' },
          change = { text = '▎' },
          delete = { text = '' },
          topdelete = { text = '' },
          changedelete = { text = '▎' },
          untracked = { text = '▎' },
        },
      },
    },
    {
      'kdheepak/lazygit.nvim',
      lazy = true,
      cmd = {
        'LazyGit',
        'LazyGitConfig',
        'LazyGitCurrentFile',
        'LazyGitFilter',
        'LazyGitFilterCurrentFile',
      },
      dependencies = {
        'nvim-lua/plenary.nvim',
      },
      keys = {
        { '<leader>gg', '<cmd>LazyGit<cr>', desc = '[G]it' },
      },
    },

    -- Undo tree
    {
      'mbbill/undotree',
      config = function()
        vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = '[U]ndo History' })
      end,
    },

    -- Autoformat (Conform)
    {
      'stevearc/conform.nvim',
      event = { 'BufWritePre' },
      opts = {
        notify_on_error = false,
        format_on_save = function(bufnr)
          return { timeout_ms = 500, lsp_format = 'fallback' }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          php = { 'pint' },
          blade = { 'blade-formatter' },
        },
      },
      keys = {
        {
          '<leader>cf',
          function()
            require('conform').format { async = true, lsp_format = 'fallback' }
          end,
          desc = '[C]ode [F]ormat',
        },
      },
    },

    -- LSP & Mason setup
    {
      'neovim/nvim-lspconfig',
      dependencies = {
        { 'mason-org/mason.nvim', opts = {} },
        'mason-org/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        { 'j-hui/fidget.nvim', opts = {} },
        'saghen/blink.cmp',
      },
      config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
          callback = function(ev)
            local map = function(keys, func, desc, mode)
              mode = mode or 'n'
              vim.keymap.set(mode, keys, func, { buffer = ev.buf, desc = 'LSP: ' .. desc })
            end
            local telescope = require 'telescope.builtin'
            map('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
            map('gr', telescope.lsp_references, '[G]oto [R]eferences')
            map('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
            map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
            map('gO', telescope.lsp_document_symbols, 'Open Document Symbols')
            map('gW', telescope.lsp_workspace_symbols, 'Open Workspace Symbols')
            map('<leader>cr', vim.lsp.buf.rename, '[R]ename')
            map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
            map('gK', vim.lsp.buf.signature_help, 'Signature Help')
          end,
        })

        local severity_labels = {
          [vim.diagnostic.severity.ERROR] = 'Error',
          [vim.diagnostic.severity.WARN] = 'Warn',
          [vim.diagnostic.severity.INFO] = 'Info',
          [vim.diagnostic.severity.HINT] = 'Hint',
        }

        vim.diagnostic.config {
          severity_sort = true,
          underline = { severity = vim.diagnostic.severity.ERROR },
          signs = false,
          virtual_text = {
            source = 'if_many',
            spacing = 2,
            prefix = '●',
            format = function(diagnostic)
              local label = severity_labels[diagnostic.severity] or ''
              return string.format('%s: %s', label, diagnostic.message)
            end,
          },
        }

        local capabilities = require('blink.cmp').get_lsp_capabilities()

        local servers = {
          lua_ls = { enable = true },
          phpactor = { enable = true },
          html = { enable = false },
          tailwindcss = { enable = true, filetypes = { 'blade', 'html', 'svelte' } },
        }

        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
          'stylua',
        })

        require('mason-tool-installer').setup { ensure_installed = ensure_installed }
        require('mason-lspconfig').setup {
          ensure_installed = {},
          automatic_installation = false,
          handlers = {
            function(server_name)
              local server = servers[server_name] or {}
              server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
              require('lspconfig')[server_name].setup(server)
            end,
          },
        }
      end,
    },

    -- Completion
    {
      'saghen/blink.cmp',
      event = 'InsertEnter',
      dependencies = {
        {
          'L3MON4D3/LuaSnip',
          version = '2.*',
          build = (function()
            return 'make install_jsregexp'
          end)(),
          dependencies = {
            {
              'rafamadriz/friendly-snippets',
              config = function()
                require('luasnip.loaders.from_vscode').lazy_load()
              end,
            },
          },
          opts = {},
        },
        { 'zbirenbaum/copilot.lua' },
        { 'giuxtaposition/blink-cmp-copilot' },
      },
      opts = {
        fuzzy = {
          prebuilt_binaries = {
            download = false,
          },
        },
        keymap = {
          preset = 'default',
        },
        appearance = {
          nerd_font_variant = 'normal',
        },
        completion = {
          ghost_text = { enabled = true },
          documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = 'single' } },
        },
        sources = {
          default = { 'copilot', 'lsp', 'path', 'snippets', 'buffer' },
          providers = {
            copilot = {
              name = 'copilot',
              module = 'blink-cmp-copilot',
              score_offset = 100,
              async = true,
            },
          },
        },
        snippets = { preset = 'luasnip' },
        fuzzy = { implementation = 'lua' },
        cmdline = { enabled = true },
        signature = { enabled = true },
      },
    },

    -- Copilot (popup only, no inline)
    {
      'zbirenbaum/copilot.lua',
      cmd = 'Copilot',
      build = ':Copilot auth',
      event = 'BufReadPost',
      config = function()
        require('copilot').setup {
          suggestion = {
            enabled = false,
            auto_trigger = true,
            debounce = 75,
            keymap = {
              accept = false,
              accept_word = false,
              accept_line = false,
              next = '<M-]>',
              prev = '<M-[>',
              dismiss = '<C-]>',
            },
          },
          panel = { enabled = false },
        }
      end,
    },

    -- Flutter tools
    {
      'nvim-flutter/flutter-tools.nvim',
      lazy = false,
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        require('flutter-tools').setup {}
        require('telescope').load_extension 'flutter'
      end,
      keys = {
        { '<leader>fd', ':FlutterDebug<CR>', desc = '[F]lutter [D]ebug' },
        { '<leader>fr', ':FlutterReload<CR>', desc = '[F]lutter [R]eload' },
        { '<leader>fR', ':FlutterRestart<CR>', desc = '[F]lutter [R]estart' },
        { '<leader>ff', ':Telescope flutter commands<CR>', desc = '[F]lutter [P]roject commands' },
      },
    },
    {
      'rcarriga/nvim-dap-ui',
      dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
      config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'
        dapui.setup {}
        dap.listeners.after.event_initialized['dapui_config'] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated['dapui_config'] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited['dapui_config'] = function()
          dapui.close()
        end

        map('n', '<leader>dd', dapui.toggle, { desc = '[D]ebug UI' })
        map('n', '<leader>db', dap.toggle_breakpoint, { desc = '[D]ebug [B]reakpoint' })
        map('n', '<F5>', dap.continue, { desc = 'Debug [C]ontinue' })

        vim.api.nvim_set_hl(0, 'DapBreakpointColor', { fg = '#ffffff', bg = '#FF5555' })
        vim.api.nvim_set_hl(0, 'DapStoppedColor', { fg = '#ffffff', bg = '#FFB86C' })
        vim.fn.sign_define('DapBreakpoint', { text = '?!', texthl = 'DapBreakpointColor', linehl = '', numhl = '' })
        vim.fn.sign_define('DapStopped', { text = '!!', texthl = 'DapStoppedColor', linehl = 'DapStoppedColor', numhl = '' })
      end,
    },

    -- Laravel tools
    {
      'adalessa/laravel.nvim',
      dependencies = {
        'tpope/vim-dotenv',
        'nvim-telescope/telescope.nvim',
        'MunifTanjim/nui.nvim',
        'kevinhwang91/promise-async',
      },
      cmd = { 'Laravel' },
      keys = { { '<leader>la', ':Laravel artisan<CR>', '[L]aravel [A]rtisan' } },
      event = { 'VeryLazy' },
      config = true,
    },
    {
      'tjdevries/php.nvim',
    },

    -- Syntax highlighting (treesitter + parser config)
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
      event = 'VeryLazy',
      main = 'nvim-treesitter.configs',
      opts = {
        ensure_installed = { 'lua', 'php', 'blade', 'dart' },
        highlight = { enable = true, use_languagetree = true },
        indent = { enable = true },
      },
      config = function(plug, config)
        local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
        parser_config.blade = {
          install_info = {
            url = 'https://github.com/EmranMR/tree-sitter-blade',
            files = { 'src/parser.c' },
            branch = 'main',
          },
          filetype = 'blade',
        }
        vim.filetype.add { pattern = { ['.*%.blade%.php'] = 'blade' } }
        require(plug.main).setup(config)
      end,
    },

    -- Html utils
    {
      'windwp/nvim-ts-autotag',
      config = function()
        require('nvim-ts-autotag').setup {
          aliases = { ['blade'] = 'html' },
        }
      end,
    },
    {
      'brenoprata10/nvim-highlight-colors',
      opts = {
        render = 'virtual',
        virtual_symbol_position = 'eol',
      },
    },

    -- Persist session
    {
      'Shatur/neovim-session-manager',
      lazy = false,
      opts = {},
      config = function()
        local config = require 'session_manager.config'
        require('session_manager').setup {
          autoload_mode = config.AutoloadMode.CurrentDir,
        }
      end,
    },

    -- Scratch files useful for notes and quick edits
    {
      'LintaoAmons/scratch.nvim',
      event = 'VeryLazy',
      dependencies = {
        { 'nvim-telescope/telescope.nvim' },
      },
      config = function()
        require('scratch').setup {
          file_picker = 'telescope',
          window_cmd = 'rightbelow vsplit',
          filetypes = { 'json', 'txt', 'sh' },
        }
        vim.keymap.set('n', '<leader>ss', '<cmd>Scratch<cr>')
        vim.keymap.set('n', '<leader>so', '<cmd>ScratchOpen<cr>')
      end,
    },

    -- Nice plugin
    {
      'folke/zen-mode.nvim',
      config = function()
        require('zen-mode').setup {
          window = {
            backdrop = 1,
            height = 0.9,
            width = 0.8,
            options = {
              number = false,
              relativenumber = false,
              signcolumn = 'no',
              list = false,
              cursorline = false,
            },
          },
          plugins = {
            tmux = { enabled = true },
            options = {
              laststatus = 2,
            },
          },
        }
      end,
      vim.keymap.set('n', '<leader>zz', function()
        require('zen-mode').toggle()
      end, { desc = '[Z]en Mode' }),
    },
    {
      'folke/twilight.nvim',
      config = function()
        require('twilight').setup {
          context = -1,
          treesitter = true,
        }
      end,
    },
  },
}
