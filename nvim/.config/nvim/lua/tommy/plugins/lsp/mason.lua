return {
  -- renovate: branch=main
  "williamboman/mason.nvim",
  commit = "16ba83bfc8a25f52bb545134f5bee082b195c460",
  cmd = "Mason",
  keys = {
    { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" }
  },
  config = function()
    local mason = require("mason")
    mason.setup()
  end,
}
