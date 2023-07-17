local config = require('nvim-bard.config')

local M = {}

M.setup = function(opts)
  config.setup(opts)
end

vim.api.nvim_create_user_command("Bard",
  function()
    if not vim.fn.has('python3') then
      print('[nvim-bard] python3 is not available, please check ":help provider-python"')
    else
      require('nvim-bard.module').toggle_bard()
    end
  end,
{})

return M
