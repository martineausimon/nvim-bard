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
  dependencies = 'MunifTanjim/nui.nvim',
  config = function()
    require('nvim-bard').setup({
      bard_api_key = "xxxxxx",
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
    })
  end
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua 
use { 
  'martineausimon/nvim-bard',
  requires = 'MunifTanjim/nui.nvim',
  config = function()
    require('nvim-bard').setup({
      bard_api_key = "xxxxxx",
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
    })
  end
}
```

**⚠ `__Secure-1PSID` is private !** If you don't want to write this Bard API key in your config directly, you can store it in a local file (e.g. `$HOME/.bard_api_key`), and use the following function:

```lua
local api_key
local file = io.open('/home/user/.bard_api_key', 'r')
if file then
  local api_key = file:read()
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
