return {
  "nvim-pack/nvim-spectre",
  commit = "72f56f7585903cd7bf92c665351aa585e150af0f",
  build = false,
  cmd = "Spectre",
  opts = { open_cmd = "noswapfile vnew" },
  -- stylua: ignore
  keys = {
    { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
  },
}
