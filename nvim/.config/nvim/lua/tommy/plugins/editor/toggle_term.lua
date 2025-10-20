return {
  "akinsho/toggleterm.nvim",
  version = "*",
  lazy = false,
  keys = {
    {
      "<leader>th",
      '<cmd>exe v:count1 . "ToggleTerm direction=horizontal"<CR>',
      desc = "Open a horizontal terminal",
    },
    {
      "<leader>tv",
      '<cmd>exe v:count1 . "ToggleTerm direction=vertical size=40"<CR>',
      desc = "Open a vertical terminal",
    },
    {
      "<C-_>",
      "<cmd>ToggleTermToggleAll<CR>",
      desc = "Open a float terminal",
      mode = { "n", "x", "o", "i", "t", "s" },
    },
    {
      "<C-t>",
      "<cmd>68ToggleTerm direction=float name=float-terminal<CR>",
      desc = "Open a float terminal",
      mode = { "n", "x", "o", "i", "t", "s" },
    },
  },
  config = function()
    require("toggleterm").setup()
    local Terminal = require("toggleterm.terminal").Terminal

    local lazygit = Terminal:new({
      cmd = "lazygit",
      count = 69,
      dir = "git_dir",
      direction = "float",
      float_opts = {
        border = "double",
      },
    })

    function _lazygit_toggle()
      lazygit:toggle()
    end

    vim.api.nvim_set_keymap("n", "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })
  end
}
