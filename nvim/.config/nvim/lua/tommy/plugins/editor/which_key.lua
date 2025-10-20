return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 1000
  end,
  opts = {
    plugins = { spelling = true },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    local keys = {
      mode = { "n", "v" },
      { "<leader><tab>", group = "tabs" },
      { "<leader>a",     group = "ai suggest" },
      { "<leader>b",     group = "buffer" },
      { "<leader>c",     group = "code" },
      { "<leader>f",     group = "file/find" },
      { "<leader>g",     group = "git" },
      { "<leader>gh",    group = "hunks" },
      { "<leader>i",     group = "in line action" },
      { "<leader>j",     group = "next action" },
      { "<leader>k",     group = "prev action" },
      { "<leader>l",     group = "leetcode" },
      { "<leader>m",     group = "markdown note" },
      { "<leader>q",     group = "quit/session" },
      { "<leader>s",     group = "search" },
      { "<leader>u",     group = "ui" },
      { "<leader>w",     group = "windows" },
      { "<leader>x",     group = "diagnostics/quickfix" },
      { "[",             group = "prev" },
      { "]",             group = "next" },
      { "g",             group = "goto" },
      { "gs",            group = "surround" },
    }
    wk.add(keys)
  end,
}
