return {
  -- renovate: branch=main
  "echasnovski/mini.pairs",
  commit = "30cf2f01c4aaa2033db67376b9924fa2442c05d6",
  event = "VeryLazy",
  opts = {},
  keys = {
    {
      "<leader>up",
      function()
        local Util = require("lazy.core.util")
        vim.g.minipairs_disable = not vim.g.minipairs_disable
        if vim.g.minipairs_disable then
          Util.warn("Disabled auto pairs", { title = "Option" })
        else
          Util.info("Enabled auto pairs", { title = "Option" })
        end
      end,
      desc = "Toggle auto pairs",
    },
  },
}
