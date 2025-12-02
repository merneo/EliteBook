-- =============================================================================
-- TREESITTER SYNTAX HIGHLIGHTING PLUGIN CONFIGURATION
-- =============================================================================
-- Plugin: nvim-treesitter/nvim-treesitter
-- Purpose: Provides advanced syntax highlighting, code navigation, and text
--          object manipulation using Tree-sitter parsing libraries.
--
-- Operational Context:
--   Treesitter replaces Neovim's built-in regex-based syntax highlighting with
--   incremental parsing, providing more accurate highlighting and enabling
--   advanced features like code navigation, text objects, and refactoring.
--
-- Plugin Manager: lazy.nvim
--   - build = ":TSUpdate": Update parsers command (runs on install/update)
--   - event: Loads on buffer read/new file (lazy loading for performance)
--
-- Key Features:
--   - Syntax highlighting: Accurate, language-aware code coloring
--   - Indentation: Language-specific indentation rules
--   - Incremental selection: Text object manipulation based on syntax tree
--   - Auto-install: Automatically installs missing language parsers
--
-- Performance:
--   - Lazy loading: Only loads when buffer is opened
--   - Large file protection: Disables highlighting for files > 100 KB
--   - Incremental parsing: Only re-parses changed regions
-- =============================================================================
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",  -- Update parsers command (runs on plugin install/update)
  event = { "BufReadPost", "BufNewFile" },  -- Lazy load: Load when buffer is opened
  config = function()
    require("nvim-treesitter.configs").setup({
      -- =======================================================================
      -- LANGUAGE PARSER INSTALLATION
      -- =======================================================================
      -- ensure_installed: List of language parsers to install automatically
      --
      -- Languages Included:
      --   - System administration: bash, yaml (config files)
      --   - Web development: html, css, javascript, typescript, tsx
      --   - Systems programming: c, cpp, rust, go
      --   -- Scripting: python, lua
      --   - Documentation: markdown, markdown_inline, vimdoc
      --   - Data formats: json, yaml
      --
      -- Why These Languages:
      --   - Covers common server administration tasks
      --   - Supports infrastructure-as-code (YAML, JSON)
      --   - Includes systems programming languages
      --   - Covers web technologies (if needed for tooling)
      -- =======================================================================
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "rust",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },

      -- =======================================================================
      -- PARSER INSTALLATION MODE
      -- =======================================================================
      -- sync_install: Install parsers synchronously during Neovim startup
      --   - false: Asynchronous installation (doesn't block Neovim startup)
      --   - true: Synchronous (blocks until complete, slower startup)
      --   - Asynchronous chosen for faster startup time
      -- =======================================================================
      sync_install = false,

      -- =======================================================================
      -- AUTO-INSTALLATION
      -- =======================================================================
      -- auto_install: Automatically install missing parsers when opening buffers
      --   - true: Install parser if missing (convenient, no manual setup)
      --   - false: Require manual installation (more control)
      --   - Enabled for convenience (parsers install on-demand)
      -- =======================================================================
      auto_install = true,

      -- =======================================================================
      -- SYNTAX HIGHLIGHTING CONFIGURATION
      -- =======================================================================
      -- highlight.enable: Enable Treesitter syntax highlighting
      --   - true: Use Treesitter for syntax highlighting (replaces Vim regex)
      --   - false: Use traditional Vim syntax highlighting
      --
      -- Large File Protection:
      --   - disable function: Disables highlighting for files exceeding size limit
      --   - max_filesize: 100 KB (prevents performance issues on large files)
      --   - Rationale: Large files can cause performance degradation
      --
      -- additional_vim_regex_highlighting: Fallback to Vim regex
      --   - false: Use only Treesitter (cleaner, faster)
      --   - true: Combine Treesitter + Vim regex (more coverage, slower)
      -- =======================================================================
      highlight = {
        enable = true,
        -- Disable for very large files
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },

      -- =======================================================================
      -- INDENTATION SUPPORT
      -- =======================================================================
      -- indent.enable: Use Treesitter for language-specific indentation
      --   - true: Treesitter provides indentation rules (more accurate)
      --   - false: Use Vim's built-in indentation (less accurate)
      --   - Enabled for better indentation behavior across languages
      -- =======================================================================
      indent = {
        enable = true,
      },

      -- =======================================================================
      -- INCREMENTAL SELECTION (Text Object Manipulation)
      -- =======================================================================
      -- Purpose: Enable text object selection based on syntax tree nodes
      --
      -- Keybindings:
      --   - init_selection: <CR> - Start incremental selection
      --   - node_incremental: <CR> - Expand selection to next node
      --   - scope_incremental: <S-CR> - Expand to scope (function, block)
      --   - node_decremental: <BS> - Shrink selection to previous node
      --
      -- Use Cases:
      --   - Select entire function: Init → Expand to scope
      --   - Select expression: Init → Expand node
      --   - Precise text manipulation: Syntax-aware selection
      -- =======================================================================
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",      -- Start selection
          node_incremental = "<CR>",    -- Expand to next node
          scope_incremental = "<S-CR>", -- Expand to scope (function/block)
          node_decremental = "<BS>",    -- Shrink to previous node
        },
      },
    })
  end,
}
