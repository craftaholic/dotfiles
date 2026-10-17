return {
  -- renovate: branch=main
  "williamboman/mason.nvim",
  commit = "2a6940af80375532e5e9e7c1f2fc6319a1b7a69d",
  cmd = "Mason",
  keys = {
    { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" }
  },
  config = function()
    local mason = require("mason")
    mason.setup()
  end,
}
