-- =============================================================================
-- NEOVIM CONFIGURATION - Text Editor Configuration
-- =============================================================================
-- Author: merneo
-- Theme: Catppuccin Mocha Green
-- Platform: Wayland (via Kitty terminal emulator)
-- Purpose: Production-ready Neovim configuration optimized for server
--          administration workflows, system configuration editing, and
--          infrastructure-as-code management.
--
-- Configuration Philosophy:
--   This configuration emphasizes performance, consistency, and operational
--   efficiency over extensive plugin ecosystems. Designed for administrators
--   who need a reliable, fast editor for configuration file management,
--   script editing, and system administration tasks.
--
-- Key Features:
--   - Fast startup: lazy.nvim plugin manager (lazy loading)
--   - Vim-style navigation: hjkl keybindings (consistent with Hyprland/Tmux)
--   - Tmux integration: vim-tmux-navigator (seamless pane switching)
--   - Modern tooling: LSP, Treesitter, completion (productivity features)
--   - Theme consistency: Catppuccin Mocha Green (matches desktop theme)
--
-- Performance Optimizations:
--   - Lazy plugin loading (plugins load on demand)
--   - Minimal plugin set (only essential plugins)
--   - Fast syntax highlighting (Treesitter)
--   - Efficient completion (native LSP, no heavy completion engines)
--
-- Integration Points:
--   - Tmux: vim-tmux-navigator plugin (unified navigation)
--   - System clipboard: unnamedplus register (wl-copy/wl-paste)
--   - Terminal: Kitty remote control (opacity changes)
-- =============================================================================

-- =============================================================================
-- LEADER KEY CONFIGURATION
-- =============================================================================
-- Leader key is the prefix for custom keybindings. Space is chosen because:
--   - Easy to reach with thumb
--   - Standard in modern Vim configs
--   - Sufficient separation from text input
-- maplocalleader used for buffer-local keymaps (less common, kept same for consistency)
-- =============================================================================

vim.g.mapleader = " "           -- Primary leader key (Space)
vim.g.maplocalleader = " "      -- Buffer-local leader (also Space)

-- =============================================================================
-- PLUGIN MANAGER BOOTSTRAPPING (lazy.nvim)
-- =============================================================================
-- lazy.nvim is a modern, fast plugin manager for Neovim.
-- This bootstrapping section:
--   1. Checks if lazy.nvim is already installed
--   2. If missing, clones the repository from GitHub
--   3. Adds lazy.nvim to the runtime path so it can be loaded
--
-- Bootstrapping makes the config portable: running Neovim on a fresh
-- machine will automatically download lazy.nvim without manual setup.
-- =============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"  -- Installation path
if not vim.loop.fs_stat(lazypath) then
  -- lazy.nvim not found, perform git clone
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",       -- Shallow clone (faster, only current commit)
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",          -- Use stable branch (not development bleeding-edge)
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)   -- Add to runtime path so 'require("lazy")' works

-- =============================================================================
-- PLUGIN LOADING
-- =============================================================================
-- lazy.nvim.setup() loads all plugins defined in the 'lua/plugins/' directory.
-- Each file in that directory should return a table of plugin specifications.
--
-- Configuration:
--   - checker.enabled = false: Don't check for plugin updates on every startup
--     (reduces startup time; updates can be run manually with :Lazy update)
-- =============================================================================

require("lazy").setup("plugins", {
  checker = { enabled = false }, -- Disable automatic update check (faster startup)
})

-- =============================================================================
-- EDITOR SETTINGS (vim.opt)
-- =============================================================================
-- vim.opt is the recommended Lua API for setting options. It provides
-- sensible defaults and allows incremental modifications to list-type options.

-- =========================================================================
-- VISUAL APPEARANCE
-- =========================================================================

-- Background color hint for plugins
-- 'dark' tells plugins to use dark color schemes
vim.opt.background = "dark"

-- =========================================================================
-- CURSOR DISPLAY
-- =========================================================================

-- Highlight the line number of the cursor (not the entire line)
-- This provides a visual indicator of cursor position without creating
-- a distracting highlight across the entire window width.
vim.opt.cursorline = true         -- Enable cursor line
vim.opt.cursorlineopt = "number"  -- Highlight only line number, not whole line

-- =========================================================================
-- LINE NUMBERING
-- =========================================================================

-- Hybrid line number mode:
--   - Absolute number for current line (shows exact line number)
--   - Relative numbers for other lines (shows distance from current)
--
-- Benefits:
--   - Current line number visible (useful for goto :123 command)
--   - Relative numbers facilitate vim motions (5j = go down 5 lines)
--   - Seamless visual feedback for navigation commands
vim.opt.number = true             -- Show line numbers
vim.opt.relativenumber = true     -- Show relative numbers for other lines

-- =========================================================================
-- INDENTATION SETTINGS
-- =========================================================================

-- Tab width: 2 spaces
-- Rationale:
--   - Modern standard for web/JavaScript development
--   - Saves horizontal screen space (important on laptops)
--   - Consistent with Hyprland config (2-space indentation)
-- expandtab: Convert <Tab> keypresses to spaces (spaces-only files)
vim.opt.tabstop = 2               -- Tab character width
vim.opt.shiftwidth = 2            -- Auto-indent width
vim.opt.expandtab = true          -- Insert spaces instead of actual tabs

-- =========================================================================
-- SYSTEM CLIPBOARD INTEGRATION
-- =========================================================================

-- 'unnamedplus' syncs Vim's unnamed register (" ") with system clipboard.
-- Benefits:
--   - Copy text in Neovim, paste into browser/email
--   - Highlight text elsewhere, paste with Neovim's 'p' command
--   - Seamless clipboard sharing across applications
-- Note: Requires +clipboard support (typically available in Neovim)
vim.opt.clipboard = "unnamedplus"

-- =========================================================================
-- WINDOW SPLITTING BEHAVIOR
-- =========================================================================

-- By default, Vim splits above/left of current window.
-- These settings make splits appear below/right (more intuitive):
-- - :split creates window below current
-- - :vsplit creates window to the right
vim.opt.splitbelow = true         -- Horizontal splits go below
vim.opt.splitright = true         -- Vertical splits go right

-- =========================================================================
-- CURSOR SHAPE BY MODE (Terminal Kitty Support)
-- =========================================================================

-- Changes cursor appearance based on Vim mode:
--   - n-v-c (Normal/Visual/Command): Block cursor (stable)
--   - i-ci-ve (Insert/Completion/Select): Vertical bar (indicates insert)
--   - r-cr (Replace): Horizontal line (underline, indicates replacement)
-- Decimal numbers (ver25, hor20) specify cursor width in percentage.
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20"

-- =========================================================================
-- INVISIBLE CHARACTER VISUALIZATION
-- =========================================================================

-- Display invisible characters to catch formatting errors:
--   - Tabs: ▸ (triangular shape)
--   - Trailing spaces: · (middle dot)
--   - Non-breaking spaces: ␣ (symbol)
-- Helps prevent subtle formatting bugs (mixed tabs/spaces, trailing whitespace)
vim.opt.list = true               -- Show invisible characters
vim.opt.listchars = {
  tab = "▸ ",                     -- Visualize tabs
  trail = "·",                    -- Visualize trailing spaces
  nbsp = "␣"                      -- Visualize non-breaking spaces
}

-- =========================================================================
-- STATUS LINE
-- =========================================================================

-- 'laststatus=3' creates a single global statusline at bottom of editor
-- (instead of separate statusline for each window)
-- This saves screen real estate and provides consistent information display
vim.opt.laststatus = 3            -- Global statusline at bottom