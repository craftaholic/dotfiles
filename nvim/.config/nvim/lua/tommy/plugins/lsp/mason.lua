return {
  "williamboman/mason.nvim",
  cmd = "Mason",
  keys = {
    { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" }
  },
  config = function()
    local mason = require("mason")
    mason.setup()
  end,
}
