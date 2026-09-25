return {
  -- renovate: branch=main
  "rafamadriz/friendly-snippets",
  commit = "b4d01b0fdf3c9a549961c2f9ffe8dc09be166219",
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}
