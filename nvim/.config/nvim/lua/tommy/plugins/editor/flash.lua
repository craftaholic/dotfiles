return {
  -- renovate: branch=main
  "folke/flash.nvim",
  commit = "5f0f270fdc7c5b0c21d903ee85b9cb06f2ac636a",
  event = "VeryLazy",
  vscode = true,
  --@type Flash.Config
  opts = {},
  keys = {
    {
      "s",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
        vim.cmd("normal! zz")
      end,
      desc = "Flash"
    },
    { "S",     mode = { "n", "o", "x" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
    { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
    { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
  },
}
