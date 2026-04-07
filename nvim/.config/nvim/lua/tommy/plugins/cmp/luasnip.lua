return {
  "L3MON4D3/LuaSnip",
  commit = "dae4f5aaa3574bd0c2b9dd20fb9542a02c10471c",
  build = (not jit.os:find("Windows"))
      and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
  opts = {
    history = true,
    delete_check_events = "TextChanged",
  },
  -- stylua: ignore
  keys = {
    -- {
    --   "<tab>",
    --   function()
    --     return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
    --   end,
    --   expr = true,
    --   silent = true,
    --   mode = "i",
    -- },
    -- { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
    -- { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
  },
}
