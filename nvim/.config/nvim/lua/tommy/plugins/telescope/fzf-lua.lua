return {
  "ibhagwan/fzf-lua",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- optional, for icons
  },
  keys = {
    -- Buffer navigation
    { "<leader>,",       "<cmd>FzfLua buffers<cr>",                  desc = "Switch Buffer" },
    { "<leader>fb",      "<cmd>FzfLua buffers<cr>",                  desc = "Buffers" },
    { "<leader>fr",      "<cmd>FzfLua oldfiles<cr>",                 desc = "Recent" },

    -- Files
    { "<leader><space>", "<cmd>FzfLua files<cr>",                    desc = "Find Files (cwd dir)" },
    { "<leader>ff",      "<cmd>FzfLua files<cr>",                    desc = "Find files (root dir)" },

    -- Search
    { "<leader>fc",      "<cmd>FzfLua grep_cword<cr>",               desc = "Find Config File" },
    { "<leader>sg",      "<cmd>FzfLua live_grep actions.ctrl-g<cr>", desc = "Grep (root dir)" },
    { "<leader>sb",      "<cmd>FzfLua grep_curbuf<cr>",              desc = "Buffer" },
    { "<leader>sh",      "<cmd>FzfLua help_tags<cr>",                desc = "Help Pages" },
    { "<leader>sH",      "<cmd>FzfLua highlights<cr>",               desc = "Search Highlight Groups" },
    { "<leader>sk",      "<cmd>FzfLua keymaps<cr>",                  desc = "Key Maps" },
    { "<leader>sM",      "<cmd>FzfLua manpages<cr>",                 desc = "Man Pages" },
    { "<leader>sm",      "<cmd>FzfLua marks<cr>",                    desc = "Jump to Mark" },
    { "<leader>sR",      "<cmd>FzfLua resume<cr>",                   desc = "Resume" },
    { "<leader>sa",      "<cmd>FzfLua autocmds<cr>",                 desc = "Auto Commands" },
    { "<leader>sc",      "<cmd>FzfLua command_history<cr>",          desc = "Command History" },
    { "<leader>sC",      "<cmd>FzfLua commands<cr>",                 desc = "Commands" },
    { '<leader>s"',      "<cmd>FzfLua registers<cr>",                desc = "Registers" },

    -- Git
    { "<leader>gc",      "<cmd>FzfLua git_commits<cr>",              desc = "Git commits" },
    { "<leader>gs",      "<cmd>FzfLua git_status<cr>",               desc = "Git status" },

    -- Diagnostics (fzf-lua doesn't have split doc/workspace, fallback to full)
    { "<leader>sd",      "<cmd>FzfLua diagnostics_document<cr>",     desc = "Document Diagnostics" },
    { "<leader>sD",      "<cmd>FzfLua diagnostics_workspace<cr>",    desc = "Workspace Diagnostics" },

    -- Errors
    { "<leader>sq",      "<cmd>FzfLua quickfix<cr>",                 desc = "Quickfix" },
    { "<leader>sl",      "<cmd>FzfLua loclist<cr>",                  desc = "Location List" },
  },
  config = function()
    require("fzf-lua").setup({
      "telescope",
      winopts = {
        fullscreen = true,
        preview = {
          default = "builtin",
          border = "border",
          layout = "vertical",
          scrollbar = "float",
        },
        on_create = function()
          -- called once upon creation of the fzf main window
          vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
          vim.keymap.set("t", "<C-k>", "<Up>", { silent = true, buffer = true })
          -- vim.keymap.set("t", "<C-o><C-o>", "<Esc>", { silent = true, remap = true, desc = "Esc" })
        end,
      },
      keymap = {
        builtin = {
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
          ["<C-/>"] = "toggle-help", -- show help window
        },
        fzf = false
      },
      files = {
        prompt = 'FILES❯ ',
      },
    })
  end,
}
