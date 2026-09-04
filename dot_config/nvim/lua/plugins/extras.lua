return {
  -- Colorizer: Highlights hex colors (#ff0000) directly in your files
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      filetypes = { "*" },
      user_default_options = {
        names = true,        -- Highlight color names like "Blue"
        RGB = true,          -- #RGB hex codes
        RRGGBB = true,       -- #RRGGBB hex codes
        RRGGBBAA = true,     -- #RRGGBBAA hex codes
        mode = "background", -- Set the display mode
      },
    },
  },

  -- Smear Cursor: Animated liquid cursor trail (matches Kitty's cursor trail)
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.5,
    },
  },
}
