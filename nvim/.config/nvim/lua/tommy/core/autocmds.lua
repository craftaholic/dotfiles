-- This file is automatically loaded by lazyvim.config.init.

local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- -- resize splits if window got resized
-- vim.api.nvim_create_autocmd({ "VimResized" }, {
--   group = augroup("resize_splits"),
--   callback = function()
--     local current_tab = vim.fn.tabpagenr()
--     vim.cmd("tabdo wincmd =")
--     vim.cmd("tabnext " .. current_tab)
--   end,
-- })

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- vim.api.nvim_create_autocmd('VimEnter', {
--   callback = function()
--     if vim.fn.argc(-1) == 1 then
--       local stat = vim.loop.fs_stat(vim.fn.argv(0))
--       if stat and stat.type == "directory" then
--         vim.cmd.bdelete()
--         require("neo-tree.command").execute({ reveal = false, toggle = true, dir = vim.loop.cwd(), position = "current" })
--       end
--     end
--   end,
-- })

-- Close all buffers that are not listed and not modified
local function close_stray_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)

    if
        name == "" -- No filepath
        and vim.api.nvim_buf_is_loaded(buf)
        and not vim.api.nvim_buf_get_option(buf, "modified")
        and vim.api.nvim_buf_get_option(buf, "buflisted")
        and vim.api.nvim_buf_get_option(buf, "buftype") == ""
    then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

-- When entering a normal buffer remove all empty buffers
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.defer_fn(close_stray_buffers, 1)
  end,
})

-- Center cursor when entering a window
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
    local filetype = vim.api.nvim_get_option_value("filetype", { buf = buf })
    local listed = vim.api.nvim_get_option_value("buflisted", { buf = buf })
    local win_config = vim.api.nvim_win_get_config(0)
    local is_floating = win_config.relative ~= ""

    -- Only center for real file buffers in non-floating windows
    if buftype == "" and filetype ~= "" and listed and not is_floating then
      vim.cmd("normal! zz")
    end
  end,
})
