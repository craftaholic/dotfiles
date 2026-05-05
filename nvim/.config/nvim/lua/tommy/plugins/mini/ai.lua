return {
  -- renovate: branch=main
  "echasnovski/mini.ai",
  commit = "7e10ce8468c0fce4f527ae2c0e5c484f7667f73d",
  verson = "*",
  event = "VeryLazy",
  opts = function()
    -- local ai = require("mini.ai")
    return {
      n_lines = 500,
    }
  end,
  config = function(_, opts)
    require("mini.ai").setup(opts)
  end
}
