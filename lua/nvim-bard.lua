local Config = require('nvim-bard.config')

local M = {}

M.setup = function(opts)
  Config.setup(opts)
end

local mode_actions = {
  popup = function() require('nvim-bard.layout.popup').toggle() end,
  vsplit = function() require('nvim-bard.layout.tabbed').vsplit() end,
  tabnew = function() require('nvim-bard.layout.tabbed').tabnew() end,
}

vim.api.nvim_create_user_command("Bard",
  function()
    if not vim.fn.has('python3') then
      print('[nvim-bard] python3 is not available, please check ":help provider-python"')
    else
      local display_mode = Config.options.display_mode
      local action = mode_actions[display_mode]
      if action then
        action()
      else
        print('[nvim-bard] Invalid display mode specified')
      end
    end
  end,
{})

return M
