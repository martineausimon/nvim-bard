# nvim-bard

**nvim-bard** is a minimal plugin to interact with [Bard](https://bard.google.com) using [bardapi](https://github.com/dsdanielpark/Bard-API) python package.

<p align="center">
<img src="https://user-images.githubusercontent.com/89019438/253833546-ecf7830b-c235-4cc8-9dad-9bf2615a0f41.png">
</p>

## Requirements

This plugin requires `bardapi`

```bash
pip install bardapi
```

## Bard API key

1. Go to [bard.google.com](https://bard.google.com)
2. Open developer tools
3. Go to Application
4. Go to Cookies
5. Copy the content of `__Secure-1PSID` in `nvim-bard` config (`bard_api_key`)

## Installation with config

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'martineausimon/nvim-bard',
  dependencies = 'MunifTanjim/nui.nvim', -- only for "popup" mode
  config = function()
    require('nvim-bard').setup({
      bard_api_key = "", --required
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
    })
  end
}
```

**⚠ `__Secure-1PSID` is private !** If you don't want to write this Bard API key in your config directly, you can store it in a local file (e.g. `$HOME/.bard_api_key`), and use the following function:

```lua
local api_key
local file = io.open('/home/user/.bard_api_key', 'r')
if file then
  api_key = file:read()
  file:close()
end

{
  'martineausimon/nvim-bard',
  dependencies = 'MunifTanjim/nui.nvim',
  config = function()
    require('nvim-bard').setup({
      bard_api_key = api_key,
    })
  end
}
```
