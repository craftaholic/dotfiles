-- Jump to older/newer cursor positions
vim.keymap.set("n", "<leader>jp", "<C-o>zz", { remap = false, desc = "Jump to next cursor position" })
vim.keymap.set("n", "<leader>kp", "<C-i>zz", { remap = false, desc = "Jump to previous cursor position" })

-- Change Esc to <C-o> keymap
vim.keymap.set({ "v", "x", "o", "s", "!", "t", "l" }, "<C-o>", "<Esc>", { silent = true, remap = true, desc = "Esc" })
vim.keymap.set({ "i", "n" }, "<C-o>", "<cmd>noh<cr><esc>", { silent = true, remap = true, desc = "Esc" })
vim.keymap.set("c", "<C-o>", "<C-c>", { silent = true, remap = true, desc = "Esc" })

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl-r> keys
vim.keymap.set("n", "<leader>wk", "<cmd>resize +20<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<leader>wj", "<cmd>resize -20<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<leader>wh", "<cmd>vertical resize -20<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<leader>wl", "<cmd>vertical resize +20<cr>", { desc = "Increase window width" })

-- Move Lines
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
-- vim.keymap.set({ "i", "n" }, "<C-c>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- taken from runtime/lua/_editor.lua
vim.keymap.set(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zvzz'", { expr = true, desc = "Next search result" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward].'zvzz'", { expr = true, desc = "Next search result" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward].'zvzz'", { expr = true, desc = "Next search result" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zvzz'", { expr = true, desc = "Prev search result" })
vim.keymap.set("x", "N", "'nN'[v:searchforward].'zvzz'", { expr = true, desc = "Prev search result" })
vim.keymap.set("o", "N", "'nN'[v:searchforward].'zvzz'", { expr = true, desc = "Prev search result" })

-- save all files
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>wa!<cr><esc>", { desc = "Save file" })

-- lazy
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- stylua: ignore start

if vim.lsp.inlay_hint then
  vim.keymap.set("n", "<leader>uh", function() vim.lsp.inlay_hint(0, nil) end, { desc = "Toggle Inlay Hints" })
end

vim.keymap.set("n", "<leader>uT",
  function() if vim.b.ts_highlight then vim.treesitter.stop() else vim.treesitter.start() end end,
  { desc = "Toggle Treesitter Highlight" })

-- quit
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Terminal Mappings
vim.keymap.set("t", "<C-n>", "<c-\\><c-n>", { silent = true, remap = false, desc = "Esc" })
vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
vim.keymap.set("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
vim.keymap.set("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
vim.keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
vim.keymap.set("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
vim.keymap.set("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
vim.keymap.set("n", "<leader>wq", "<C-W>c", { desc = "Delete window", remap = true })
vim.keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
vim.keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- Navigate
vim.keymap.set("n", "j", "jzz", { desc = "Go down and center" })
vim.keymap.set("n", "k", "kzz", { desc = "Go up and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Go down and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Go up and center" })

-- Navigate buffer page horizontal
vim.keymap.set("n", "<C-i>", "4zl", { remap = true, desc = "Scrol tab/buffer to the right" })
vim.keymap.set("n", "<C-e>", "4zh", { remap = true, desc = "Scrol tab/buffer to the left" })

-- Delete and Enter file above and below
vim.keymap.set("n", "<BS>", "k\"_dd", { desc = "Delete line above" })
vim.keymap.set("n", "<CR>", "O<Esc>j", { desc = "Bring this line down to a newline" })

vim.keymap.set("x", "<Tab>", ">gv", { desc = "Tab indent selection to the right" })
vim.keymap.set("x", "<S-Tab>", "<gv", { desc = "Tab indent selection to the left" })

-- This is for delete change, replace action to be do under _ registry
vim.keymap.set({ "n" }, "p", '"+p', { desc = "Paste from clipboard to the right of cursor" })
vim.keymap.set({ "n" }, "P", '"+P', { desc = "Paste from clipboard to the left of cursor" })

-- Greatest keymap ever for VsCode like copy and paste
vim.keymap.set({ "x", "v" }, "p", "\"_dP", { remap = true, desc = "Paste from clipboard overwrite the selection" })

vim.keymap.set({ "n", "x", "v" }, "y", '"+y', { desc = "Yank to clipboard" })

vim.keymap.set({ "n", "v", "x" }, "r", '"_r', { desc = "Replace and send deleted char to blackhole register" })
vim.keymap.set({ "n", "v", "x" }, "d", '"_d', { desc = "Delete to blackhole register" })
vim.keymap.set({ "n", "v", "x" }, "x", '"_x', { desc = "Delete current character under cursor to blackhole register" })
vim.keymap.set({ "n", "v", "x" }, "c", '"_c', { desc = "Change option and send deleted strings to blackhole register" })

vim.keymap.set({ "n", "v", "x" }, "D", '"+d', { desc = "Cut the selection" })

vim.keymap.set({ "n" }, "<leader>id", "0\"_d$", { desc = "Delete content of the line but keep the line exists" })
vim.keymap.set({ "n" }, "<leader>iD", "0\"+d$", { desc = "Cut content of the line but keep the line exists" })

vim.keymap.set({ "n" }, "<leader>iy", "0y$", { desc = "Copy the content of a line" })

-- This is for global selection
vim.keymap.set({ "n", "i" }, "<C-a>", function() vim.cmd("normal! ggVG") end, { desc = "Global selection" })

-- vim.keymap.set({ "n", "v", "x" }, "<leader>lt", "<cmd>Leet tabs<cr>", { desc = "Open question lists" })
-- vim.keymap.set({ "n", "v", "x" }, "<leader>lc", "<cmd>Leet console<cr>", { desc = "Open console" })
-- vim.keymap.set({ "n", "v", "x" }, "<leader>li", "<cmd>Leet info<cr>", { desc = "Open question info" })
-- vim.keymap.set({ "n", "v", "x" }, "<leader>ls", "<cmd>Leet submit<cr>", { desc = "Submit the answer" })
-- vim.keymap.set({ "n", "v", "x" }, "<leader>lr", "<cmd>Leet random<cr>", { desc = "Select a random question" })
-- vim.keymap.set({ "n", "v", "x" }, "<leader>ld", "<cmd>Leet desc<cr>", { desc = "Toggle question description" })
-- vim.keymap.set({ "n", "v", "x" }, "<leader>ll", "<cmd>Leet lang<cr>", { desc = "Select language question" })
-- vim.keymap.set({ "n", "v", "x" }, "<leader>lm", "<cmd>Leet menu<cr>", { desc = "Go to menu page" })
