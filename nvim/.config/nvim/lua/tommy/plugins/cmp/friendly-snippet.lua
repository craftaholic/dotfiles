return {
  "rafamadriz/friendly-snippets",
  commit = "6cd7280adead7f586db6fccbd15d2cac7e2188b9",
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}
