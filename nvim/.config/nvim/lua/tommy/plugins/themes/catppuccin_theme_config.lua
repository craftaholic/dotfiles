return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    background = {     -- :h background
      light = "latte",
      dark = "frappe",
    },
    transparent_background = true, -- disables setting the background color.
    show_end_of_buffer = true,     -- shows the '~' characters after the end of buffers
    term_colors = true,            -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
      enabled = false,             -- dims the background color of inactive window
      shade = "dark",
      percentage = 0.3,            -- percentage of the shade to apply to the inactive window
    },
    no_italic = false,             -- Force no italic
    no_bold = false,               -- Force no bold
    no_underline = false,          -- Force no underline
    styles = {                     -- Handles the styles of general hi groups (see `:h highlight-args`):
      comments = { "italic" },     -- Change the style of comments
      conditionals = { "italic" },
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    color_overrides = {
      frappe = {
        base = "#010c14",
        -- mantle = "#422b11",
        crust = "#5756a8",
      },
      macchiato = {
        -- base = "#000000",
        -- mantle = "#422b11",
        crust = "#5756a8",
      }
    },
    custom_highlights = {},
    integrations = {
      cmp = true,
      gitsigns = true,
      neotree = true,
      treesitter = true,
      which_key = true,
      mini = {
        enabled = true,
        indentscope_color = "",
      },
    },
  },
}
