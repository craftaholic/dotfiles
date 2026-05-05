return {
  -- renovate: branch=main
  "williamboman/mason.nvim",
  commit = "cb8445f8ce85d957416c106b780efd51c6298f89",
  cmd = "Mason",
  keys = {
    { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" }
  },
  config = function()
    local mason = require("mason")
    mason.setup()
  end,
}
