local Config = require('nvim-bard.config')

local M = {}

local bard_api_key = Config.options.bard_api_key

function M.check_api_key()
  if bard_api_key == "" then
    print("[nvim-bard] No bard api key")
    return false
  else
    return true
  end
end

function M.load()
  local py_lines = {
    'from bardapi import Bard, SESSION_HEADERS',
    'import os',
    'import requests',
    'session = requests.Session()',
    'session.headers = SESSION_HEADERS',
  }
  if type(bard_api_key) == 'string' then
    table.insert(py_lines, string.format('session.cookies.set("__Secure-1PSID", "%s")', bard_api_key))
    table.insert(py_lines, string.format('bard = Bard(token="%s", session=session, timeout=30)', bard_api_key))
  elseif type(bard_api_key) == 'table' then
    table.insert(py_lines, string.format('session.cookies.set("__Secure-1PSID", "%s")', bard_api_key.psid))
    table.insert(py_lines, string.format('session.cookies.set("__Secure-1PSIDCC", "%s")', bard_api_key.psidcc))
    table.insert(py_lines, string.format('session.cookies.set("__Secure-1PSIDTS", "%s")', bard_api_key.psidts))
    table.insert(py_lines, string.format('bard = Bard(token="%s", session=session, timeout=30)', bard_api_key.psid))
  end
  for _, line in ipairs(py_lines) do
    vim.fn.execute(string.format('py3 %s', line))
  end
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
