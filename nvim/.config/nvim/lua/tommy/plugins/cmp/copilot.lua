return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "InsertEnter",
  opts = {
    {
      panel = {
        enabled = false,
        auto_refresh = true,
        keymap = {
          jump_prev = "<leader>ks",
          jump_next = "<leader>js",
          accept = "<CR>",
          refresh = "<leader>ar",
          open = "<leader>ap"
        },
        layout = {
          position = "right", -- | top | left | right
          ratio = 0.4
        },
      },
      suggestion = {
        enabled = false,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          accept = "<Tab>",
          accept_word = false,
          accept_line = false,
          next = "<leader>ja",
          prev = "<leader>ka",
          dismiss = "<C-<CR>>",
        },
      },
      filetypes = {
        yaml = true,
        markdown = true,
        help = true,
        ["*"] = true,
      },
      copilot_node_command = 'node', -- Node.js version must be > 18.x
      server_opts_overrides = {},
    }
  },
  config = function(_, opts)
    require("copilot").setup({opts})
  end,
}
