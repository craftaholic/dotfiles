return {
  'mfussenegger/nvim-jdtls',
  ft = 'java',
  dependencies = { 'hrsh7th/cmp-nvim-lsp' },
  config = function()
    local jdtls = require('jdtls')

    local function get_config()
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
      local workspace_dir = vim.fn.expand('~/.cache/jdtls/workspace/') .. project_name
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      return {
        cmd = {
          'jdtls',
          '--jvm-arg=-javaagent:' .. vim.fn.expand('~/Documents/devtools/lombok/lombok.jar'),
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
