-- ~/.config/nvim/init.lua

-- =====================================================================
-- 1. Essential Settings
-- =====================================================================
vim.opt.number = true
vim.opt.relativenumber = false
-- vim.opt.laststatus = 0
vim.opt.ruler = false
-- vim.opt.cmdheight = 0
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.statusline = " %F %m %= %l:%c "
vim.opt.clipboard = "unnamedplus"
-- vim.opt.clipboard:append({ "unnamed", "unnamedplus" })

-- =====================================================================
-- 1. Bootstrap Lazy.nvim (The Plugin Manager)
-- =====================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key BEFORE loading plugins
vim.g.mapleader = " "

-- =====================================================================
-- 2. Load Plugins
-- =====================================================================
require("lazy").setup({
    -- Colorizer: Highlights hex colors in your config files
    {
        "NvChad/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({
                user_default_options = {
                    names = true,        -- Highlight color names like "Blue"
                    RGB = true,          -- #RGB hex codes
                    RRGGBB = true,       -- #RRGGBB hex codes
                    RRGGBBAA = true,     -- #RRGGBBAA hex codes
                    mode = "background", -- Set the display mode
                },
                -- This tells the plugin to stay active on all file types
                filetypes = { "*" },
            })
        end
    },

    -- Treesitter: Beautiful, rich syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            -- We wrap it in a pcall (protected call) so it never crashes Neovim
            -- even if it takes a second to download!
            local ok, configs = pcall(require, "nvim-treesitter.configs")
            if ok then
                configs.setup({
                    ensure_installed = { "lua", "bash", "css", "toml", "json" },
                    highlight = { enable = true },
                })
            end
        end
    },

    -- Noctalia Colorscheme (Base16 / Matugen)
    {
        "RRethy/base16-nvim",
        lazy = false,
        priority = 1000,
        config = function()
            local function make_transparent()
                local groups = {
                    "Normal",
                    "NormalNC",
                    "NormalFloat",
                    "FloatBorder",
                    "SignColumn",
                    "FoldColumn",
                    "LineNr",
                    "CursorLineNr",
                    "EndOfBuffer",
                }
                for _, group in ipairs(groups) do
                    vim.api.nvim_set_hl(0, group, { bg = "none", ctermbg = "none" })
                end
            end

            -- Ensure base16 setup preserves transparency even when reloaded via SIGUSR1
            local ok_base16, base16 = pcall(require, "base16-colorscheme")
            if ok_base16 then
                local orig_setup = base16.setup
                base16.setup = function(colors, config)
                    orig_setup(colors, config)
                    make_transparent()
                end
            end

            local ok_matugen, matugen = pcall(require, "matugen")
            if ok_matugen then
                matugen.setup()
            end
            make_transparent()

            vim.api.nvim_create_autocmd({ "ColorScheme", "UIEnter" }, {
                callback = make_transparent,
            })
        end,
    },
})

-- =====================================================================
-- 3. Cool Built-in Tweaks
-- =====================================================================
-- Flash text briefly when you copy it
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", {}),
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})
