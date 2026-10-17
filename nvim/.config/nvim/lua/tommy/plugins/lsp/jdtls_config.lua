return {
  'mfussenegger/nvim-jdtls',
  commit = "6e9d953f0b82bccdb834cfde0e893f3119c22592",
  ft = 'java',
  dependencies = { { "hrsh7th/cmp-nvim-lsp", commit = "cbc7b02bb99fae35cb42f514762b89b5126651ef" } },
  config = function()
    local jdtls = require('jdtls')

    local function get_config()
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      return {
        cmd = {
          'jdtls',
          '--jvm-arg=-javaagent:' .. vim.fn.expand('~/.local/devtools/java/lombok/lombok.jar'),
          '-data', workspace_dir,
        },
        root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', '.git', 'mvnw', 'pom.xml' }, { upward = true })[1]),
        capabilities = capabilities,
        settings = {
          java = {
            references = { includeDecompiledSources = true },
            eclipse = { downloadSources = true },
            maven = { downloadSources = true },
          },
        },
      }
    end

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      callback = function()
        jdtls.start_or_attach(get_config())
      end,
    })
  end,
}
