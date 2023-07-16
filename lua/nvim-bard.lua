local config = require('nvim-bard.config')

local M = {}

M.setup = function(opts)
  config.setup(opts)
end

vim.api.nvim_create_user_command("Bard",
  function()
    require('nvim-bard.module').toggle_bard()
  end,
{})

return M
