local Config = require('nvim-bard.config')
local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local bard_api_key = Config.options.bard_api_key
local send_bard = Config.options.mappings.send_bard
local new_chat = Config.options.mappings.new_chat

local bard_status

local bardapi = [[
python3 << END
from bardapi import Bard
import os
import requests

session = requests.Session()
session.headers = {
  "Host": "bard.google.com",
  "X-Same-Domain": "1",
  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36",
  "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
  "Origin": "https://bard.google.com",
  "Referer": "https://bard.google.com/",
}
session.cookies.set("__Secure-1PSID", token) 

bard = Bard(token=token, session=session, timeout=30)
END
]]

local layout, top_popup, bottom_popup

local M = {}

function M.toggle_bard()
  if bard_api_key == "" then
    print("nvim-bard: No bard api key")
  do return end
  end
  if bard_status == "open" then
    layout:hide()
    bard_status = "hidden"
  elseif bard_status == "hidden" then
    layout:show()
    bard_status = "open"
  else
    bard_status = "open"
    M.create_layout()
  end
end

function M.create_layout()
  top_popup = Popup({
    border = {
      style = "single",
      text = {
        top = "[Bard]"
      }
    }
  })

  bottom_popup = Popup({
    enter = true,
    border = {
      style = "single",
      text = {
        top = "[Query]"
      }
    }
  })

  layout = Layout(
    {
      position = "50%",
      size = {
        width = "90%",
        height = "90%",
      },
    },
    Layout.Box({
      Layout.Box(top_popup, { size = "80%" }),
      Layout.Box(bottom_popup, { size = "20%" }),
    }, { dir = "col" })
  )

  top_popup:on(event.BufWinEnter, function()
    vim.cmd('set filetype=markdown')
    vim.fn.matchadd("Identifier", [[\[?\] ]])
    vim.fn.matchadd("Statement", [[\[✦\] ]])
  end)

  bottom_popup:on(event.BufWinEnter, function()
    vim.cmd('startinsert')
  end)

  bottom_popup:on(event.BufWipeout, function()
    bard_status = nil
  end)

  vim.api.nvim_buf_create_user_command(bottom_popup.bufnr, "BardReset",
    function()
      vim.api.nvim_buf_call(top_popup.bufnr, function()
        vim.cmd('normal gg')
      end)
      vim.api.nvim_buf_set_lines(bottom_popup.bufnr, 0, -1, false, {})
      vim.api.nvim_buf_set_lines(top_popup.bufnr, 0, -1, false, {})
    end,
  {})
  vim.api.nvim_buf_set_keymap(bottom_popup.bufnr, "n", new_chat, "<cmd>BardReset<cr>", {})

  vim.api.nvim_buf_create_user_command(bottom_popup.bufnr, "BardSend", function() M.get_content() end, {})
  vim.api.nvim_buf_set_keymap(bottom_popup.bufnr, "n", send_bard, "<cmd>BardSend<cr>", {})

  layout:mount()
end

function M.get_content()
  local lines = vim.api.nvim_buf_get_lines(bottom_popup.bufnr, 0, -1, false)
  local query  = table.concat(lines, "\n")
  lines[1] = "[?] " .. lines[1]
  table.insert(lines, "")
  local top_buf_lines = vim.api.nvim_buf_get_lines(top_popup.bufnr, 0, -1, false)
  if #top_buf_lines > 1 then
    vim.api.nvim_buf_set_lines(top_popup.bufnr, -1, -1, false, lines)
  else
    vim.fn.execute([[py3 token = "]] .. bard_api_key .. [["]])
    vim.api.nvim_buf_set_lines(top_popup.bufnr, 0, -1, false, lines)
    vim.defer_fn(function() vim.cmd(bardapi) end, 0)
  end
  vim.api.nvim_buf_set_lines(bottom_popup.bufnr, 0, -1, false, {})
  vim.defer_fn(function()
    M.ask_bard(query)
  end, 0)
end

function M.ask_bard(query)
  local escaped_query = vim.fn.escape(query, [["\()]])
  vim.fn.execute([[py3 answer = bard.get_answer("""]] .. escaped_query .. [["""]] .. ")['content']")
  local result = vim.fn.execute("py3 print(answer)")
  local lines = {}
  for line in result:gmatch("[^\r\n]+") do
    line = line:gsub("%^M", "")
    table.insert(lines, line)
  end
  lines[1] = "[✦] " .. lines[1]
  table.insert(lines, "")
  vim.api.nvim_buf_set_lines(top_popup.bufnr, -1, -1, false, lines)
  vim.api.nvim_buf_call(top_popup.bufnr, function()
    vim.cmd('normal G')
  end)
end

return M
