return {
  "neovim/nvim-lspconfig",
  event = { 'BufEnter', 'BufNewFile' },
  config = function()
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Set default filetype of ft to terraform
    vim.cmd([[
      augroup terraform_filetype
        autocmd!
        autocmd BufNewFile,BufRead *tf set filetype=terraform
      augroup END
    ]])

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

    -- Adding default capabilities to all servers
    vim.lsp.config('*', {
      capabilities = capabilities,
    })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('my.lsp', {}),
      callback = function(args)
        local opts = { noremap = true, silent = true, buffer = args.buf }
        local keymap = vim.keymap

        local function checkBufferMethod(method)
          for _, curentClient in pairs(vim.lsp.get_clients({ bufnr = args.buf })) do
            if curentClient:supports_method(method) then
              return true
            end
          end
          return false
        end

        -- General LSP-related keymaps
        opts.desc = "Show LSP references"
        keymap.set("n", "<leader>cR", "<cmd>FzfLua lsp_references<CR>", opts)

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>crs", ":LspRestart<CR>", opts)

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>cD", "<cmd>FzfLua diagnostics_document<CR>", opts)


        -- diagnostic
        local diagnostic_goto = function(next, severity)
          local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
          severity = severity and vim.diagnostic.severity[severity] or nil
          return function()
            go({ severity = severity })
            vim.cmd("normal! zz")
          end
        end

        vim.keymap.set("n", "<leader>jd", diagnostic_goto(true), { desc = "Next Diagnostic" })
        vim.keymap.set("n", "<leader>kd", diagnostic_goto(false), { desc = "Prev Diagnostic" })
        vim.keymap.set("n", "<leader>je", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
        vim.keymap.set("n", "<leader>ke", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
        vim.keymap.set("n", "<leader>jw", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
        vim.keymap.set("n", "<leader>kw", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>cd", vim.diagnostic.open_float, opts)

        opts.desc = "Show dynamic workspace symbols"
        keymap.set("n", "<leader>css", "<cmd>FzfLua lsp_workspace_symbols<CR>", opts)

        -- Per-capability mappings
        if checkBufferMethod('textDocument/declaration') then
          opts.desc = "Go to declaration"
          keymap.set("n", "gD", "<cmd>FzfLua lsp_declarations", opts)
        else
          opts.desc = "Declaration not supported"
          keymap.set("n", "gD", function() print("LSP: declaration not supported") end, opts)
        end

        if checkBufferMethod('textDocument/definition') then
          opts.desc = "Show LSP definitions"
          keymap.set("n", "gd", "<cmd>FzfLua lsp_definitions<CR>", opts)
        else
          opts.desc = "Definition not supported"
          keymap.set("n", "gd", function() print("LSP: definition not supported") end, opts)
        end

        if checkBufferMethod('textDocument/implementation') then
          opts.desc = "Show LSP implementations"
          keymap.set("n", "<leader>ci", "<cmd>FzfLua lsp_implementations<CR>", opts)
        else
          opts.desc = "Implementation not supported"
          keymap.set("n", "<leader>ci", function() print("LSP: implementation not supported") end, opts)
        end

        if checkBufferMethod('textDocument/typeDefinition') then
          opts.desc = "Show LSP type definitions"
          keymap.set("n", "<leader>ct", "<cmd>FzfLua lsp_typedefs<CR>", opts)
        else
          opts.desc = "Type definition not supported"
          keymap.set("n", "<leader>ct", function() print("LSP: type definition not supported") end, opts)
        end

        if checkBufferMethod('textDocument/codeAction') then
          opts.desc = "See available code actions"
          keymap.set({ "n", "v" }, "<leader>ca", "<cmd>FzfLua lsp_code_actions<CR>", opts)
        else
          opts.desc = "Code action not supported"
          keymap.set({ "n", "v" }, "<leader>ca", function() print("LSP: code action not supported") end, opts)
        end

        if checkBufferMethod('textDocument/rename') then
          opts.desc = "Smart rename"
          keymap.set("n", "<leader>crn", vim.lsp.buf.rename, opts)
        else
          opts.desc = "Rename not supported"
          keymap.set("n", "<leader>crn", function() print("LSP: rename not supported") end, opts)
        end
      end,
    })

    -- configure lua server (with special settings)
    vim.lsp.config('lua_ls',
      {
        settings = { -- custom settings for lua
          Lua = {
            -- make the language server recognize "vim" global
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              -- make language server aware of runtime files
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
          },
        },
      }
    )

    -- configure java server (with special settings)
    vim.lsp.config("jdtls",
      {
        cmd = { 'jdtls' },
        -- root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw' }, { upward = true })[1]),
      })

    vim.lsp.config("pyright",
      {
        root_dir = vim.fs.dirname(vim.fs.find({ 'pyproject.toml', '.git', '.venv' }, { upward = true })[1]),
      })
  end,
}
