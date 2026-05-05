return {
  -- renovate: branch=main
  "williamboman/mason-lspconfig.nvim",
  commit = "0c2823e0418f3d9230ff8b201c976e84de1cb401",
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
