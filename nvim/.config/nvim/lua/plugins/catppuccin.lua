-- =============================================================================
-- CATPPUCCIN COLOR SCHEME PLUGIN CONFIGURATION
-- =============================================================================
-- Plugin: catppuccin/nvim
-- Purpose: Provides Catppuccin Mocha Green color scheme for Neovim, ensuring
--          visual consistency with the overall desktop theme (Hyprland, Waybar,
--          Kitty, etc.).
--
-- Plugin Manager: lazy.nvim
--   - Priority: 1000 (loads early, before other plugins)
--   - Lazy: false (loads immediately on Neovim startup)
--   - Rationale: Color scheme must be applied before other plugins render
--
-- Configuration:
--   - flavour: "mocha" (dark theme variant)
--   - transparent_background: false (opaque background for readability)
--   - show_end_of_buffer: false (clean buffer end, no tilde characters)
--
-- Integrations:
--   - native_lsp: LSP diagnostic styling (errors, warnings, hints)
--   - treesitter: Syntax highlighting theme integration
--   - telescope: Fuzzy finder theme integration
--
-- Custom Highlights:
--   - LineNr: Muted line numbers (doesn't compete with code)
--   - CursorLineNr: Green accent, bold (clear current line indicator)
--   - WinBar: Window bar background (matches base color)
-- =============================================================================
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,  -- High priority: Load early (color scheme must be set before other plugins)
  lazy = false,     -- Load immediately: Color scheme needed at startup
  config = function()
    require("catppuccin").setup({
      -- =======================================================================
      -- COLOR SCHEME VARIANT
      -- =======================================================================
      -- flavour: Color scheme variant selection
      --   - "mocha": Dark theme with rich colors (current selection)
      --   - Alternatives: "latte" (light), "frappe" (dark), "macchiato" (dark)
      --   - Mocha chosen for consistency with desktop theme
      -- =======================================================================
      flavour = "mocha",
      
      -- =======================================================================
      -- BACKGROUND TRANSPARENCY
      -- =======================================================================
      -- transparent_background: Enable transparent background
      --   - false: Opaque background (better text readability)
      --   - true: Transparent (allows terminal background to show through)
      --   - Opaque chosen for maximum readability during long editing sessions
      -- =======================================================================
      transparent_background = false,
      
      -- =======================================================================
      -- BUFFER END DISPLAY
      -- =======================================================================
      -- show_end_of_buffer: Display tilde characters at end of buffer
      --   - false: Clean buffer end (no visual clutter)
      --   - true: Show tildes (traditional Vim behavior)
      --   - Disabled for cleaner, modern appearance
      -- =======================================================================
      show_end_of_buffer = false,
      
      -- =======================================================================
      -- PLUGIN INTEGRATIONS
      -- =======================================================================
      -- Purpose: Configure how Catppuccin theme integrates with other Neovim plugins
      --
      -- native_lsp: Language Server Protocol diagnostic styling
      --   - enabled: true - Apply theme to LSP diagnostics
      --   - virtual_text: Italic styling for inline diagnostics
      --   - underlines: Underline styling for diagnostic ranges
      --   - inlay_hints: Background highlighting for inlay hints
      --
      -- treesitter: Syntax highlighting integration
      --   - true: Apply theme colors to Treesitter syntax groups
      --   - Provides rich syntax highlighting with theme colors
      --
      -- telescope: Fuzzy finder theme integration
      --   - true: Apply theme to Telescope UI elements
      --   - Ensures consistent appearance in file/buffer pickers
      -- =======================================================================
      integrations = {
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },      -- Italic error messages
            hints = { "italic" },        -- Italic hint messages
            warnings = { "italic" },     -- Italic warning messages
            information = { "italic" },  -- Italic info messages
          },
          underlines = {
            errors = { "underline" },      -- Underline error ranges
            hints = { "underline" },        -- Underline hint ranges
            warnings = { "underline" },     -- Underline warning ranges
            information = { "underline" }, -- Underline info ranges
          },
          inlay_hints = {
            background = true,  -- Background highlight for inlay hints
          },
        },
        treesitter = true,   -- Enable Treesitter syntax highlighting theme
        telescope = true,    -- Enable Telescope fuzzy finder theme
      },
      
      -- =======================================================================
      -- CUSTOM HIGHLIGHT OVERRIDES
      -- =======================================================================
      -- Purpose: Customize specific highlight groups for personal preference
      --
      -- LineNr: Line number styling
      --   - fg = colors.surface1: Muted gray (doesn't compete with code)
      --   - Provides subtle line number display
      --
      -- CursorLineNr: Current line number styling
      --   - fg = colors.green: Catppuccin Green accent
      --   - style = { "bold" }: Bold font weight (clear visual indicator)
      --   - Provides clear indication of cursor position
      --
      -- WinBar: Window bar (top of window, shows file path)
      --   - bg = colors.base: Matches editor background
      --   - Seamless integration with editor window
      -- =======================================================================
      custom_highlights = function(colors)
        return {
          LineNr = { fg = colors.surface1 },                    -- Muted line numbers
          CursorLineNr = { fg = colors.green, style = { "bold" } }, -- Green, bold current line
          WinBar = { bg = colors.base },                        -- Window bar background
        }
      end,
    })
    -- =========================================================================
    -- APPLY COLOR SCHEME
    -- =========================================================================
    -- vim.cmd.colorscheme: Executes Vim command to set color scheme
    --   - "catppuccin": Activates the configured Catppuccin theme
    --   - Must be called after setup() to apply configuration
    -- =========================================================================
    vim.cmd.colorscheme "catppuccin"
  end,
}
