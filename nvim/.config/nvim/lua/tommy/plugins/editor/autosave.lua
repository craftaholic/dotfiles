return {
  "Pocco81/auto-save.nvim",
  commit = "979b6c82f60cfa80f4cf437d77446d0ded0addf0",
  config = function()
    require("auto-save").setup {
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")

        -- Exclude oil filetype
        local excluded_filetypes = { "oil" }

        if fn.getbufvar(buf, "&modifiable") == 1 and
            utils.not_in(fn.getbufvar(buf, "&filetype"), excluded_filetypes) then
          return true
        end
        return false
      end
    }
  end,
}
