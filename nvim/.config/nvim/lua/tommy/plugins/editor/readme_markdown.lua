return {
  "iamcco/markdown-preview.nvim",
  enabled = true,
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = "cd app && bun install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
}
