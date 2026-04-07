return {
  "williamboman/mason.nvim",
  commit = "44d1e90e1f66e077268191e3ee9d2ac97cc18e65",
  cmd = "Mason",
  keys = {
    { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" }
  },
  config = function()
    local mason = require("mason")
    mason.setup()
  end,
}
