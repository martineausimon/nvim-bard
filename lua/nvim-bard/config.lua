local M = {}

function M.defaults()
  local defaults = {
    bard_api_key = "",
    display_mode = "popup", -- "popup", "vsplit" or "tabnew"
    mappings = {
      toggle_bard = "<leader>b",
      hide_bard = { "q", "<esc>" },
      send_bard = "<cr>",
      new_chat = "<c-n>"
    },
    options = {
      ui = {
        question = {
          signs = {
            sign = "",
            hi = "Function",
            style = "single" -- "double", "none", "rounded", "solid"
          },
          border = { -- only for "popup" mode
            style = "single", -- "double", "none", "shadow", "rounded", "solid"
            text = {
              top = "[Prompt]"
            }
          },
          winhighlight = "Normal:Normal,FloatBorder:Normal"
        },
        bard = {
          signs = {
            sign = "🟆",
            hi = "Statement",
            style = "single"
          },
          border = {
            style = "single",
            text = {
              top = "[Bard]"
            }
          },
          winhighlight = "Normal:Normal,FloatBorder:Normal"
        }
      },
      buffer_options = {
        signcolumn = 'yes:1',
        filetype = 'markdown',
        conceallevel = 3,
        buftype = "nofile",
      },
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
