local M = {}

function M.defaults()
  local defaults = {
    bard_api_key = "",
    mappings = {
      toggle_bard = "<leader>b",
      send_bard = "<cr>",
      new_chat = "<c-n>"
    },
    options = {
      top_popup_options = {
        signcolumn = 'yes:1',
        filetype = 'markdown',
        conceallevel = 3,
      }
    }
  }
  return defaults
end

M.options = {}

function M.setup(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults(), options)

  vim.keymap.set("n", M.options.mappings.toggle_bard, "<cmd>Bard<cr>", {})
end

return M
