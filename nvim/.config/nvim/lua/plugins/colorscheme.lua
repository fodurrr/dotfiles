-- =============================================================================
-- Colorscheme: Catppuccin Mocha
-- =============================================================================
-- Matches Ghostty, tmux, Zed, and other tools
-- =============================================================================

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      term_colors = true,
      styles = {
        comments = { "italic" },
      },
      integrations = {
        aerial = true,
        cmp = true,
        gitsigns = true,
        harpoon = true,
        mason = true,
        neotree = true,
        notify = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },

  -- modicator (auto color line number based on vim mode)
  {
    "mawkler/modicator.nvim",
    dependencies = "catppuccin/nvim",
    init = function()
      vim.o.cursorline = false
      vim.o.number = true
      vim.o.termguicolors = true
    end,
    opts = {},
  },
}
