return {
  -- renovate: branch=main
  "echasnovski/mini.ai",
  commit = "25248c6aa002391936a6200f12d1466015987133",
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
