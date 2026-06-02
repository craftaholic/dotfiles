return {
  -- renovate: branch=main
  "williamboman/mason-lspconfig.nvim",
  commit = "0a695750d747db1e7e70bcf0267ef8951c95fc83",
  opts = {
    ensure_installed = {
      "gopls",
      "terraformls",
      "tflint",
      "lua_ls",
      "eslint",
      "jdtls",
      "dockerls",
    }
  }
}
