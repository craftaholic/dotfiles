return {
  -- renovate: branch=main
  "echasnovski/mini.ai",
  commit = "deacc8e9cf05df0297e3b14a08c2f8a415045c6f",
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
