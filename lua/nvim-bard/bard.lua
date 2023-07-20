local Config = require('nvim-bard.config')

local M = {}

local bard_api_key = Config.options.bard_api_key
local token = string.format('py3 token = "%s"', bard_api_key)

local session = [[
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

function M.check_api_key()
  if bard_api_key == "" then
    print("[nvim-bard] No bard api key")
    return false
  else
    return true
  end
end

function M.load()
  vim.fn.execute(token)
  vim.cmd(session)
end

function M.ask(query)
  local escaped_query = vim.fn.escape(query, [["\()]])
  local cmd = string.format('py3 answer = bard.get_answer("""%s""")["content"]', escaped_query)
  vim.fn.execute(cmd)
  local result = vim.fn.execute("py3 print(answer)")
  local lines = {}
  for line in result:gmatch("[^\r\n]+") do
    line = line:gsub("%^M", "")
    table.insert(lines, line)
  end
  return lines
end

return M
