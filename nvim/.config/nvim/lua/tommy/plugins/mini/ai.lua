return {
  "echasnovski/mini.ai",
  commit = "4b0a6207341d895b6cfe9bcb1e4d3e8607bfe4f4",
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
