return {
  "echasnovski/mini.ai",
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
