local Signs = require('nvim-bard.signs')
local Config = require('nvim-bard.config')
local Bard = require('nvim-bard.bard')

local send_bard = Config.options.mappings.send_bard
local new_chat = Config.options.mappings.new_chat
local buffer_options = Config.options.options.buffer_options

local line_count = 1

local M = {}

local bard = {}

local function buf_infos()
  local bard_bufnr = vim.fn.bufnr('nvim-bard')
  local bard_winid = vim.fn.win_findbuf(bard_bufnr)[1]
  bard = {
    bufnr = bard_bufnr,
    winid = bard_winid
  }
end

function M.vsplit()
  buf_infos()
  if M.visible(bard.bufnr) then
    vim.api.nvim_set_current_win(bard.winid)
    vim.cmd('hide')
  elseif M.exists(bard.bufnr) and not M.visible(bard.bufnr) then
    vim.cmd('vsplit nvim-bard')
  else
    M.open("vsplit")
  end
end

function M.tabnew()
  buf_infos()
  if M.visible(bard.bufnr) then
    vim.api.nvim_set_current_win(bard.winid)
    vim.cmd('hide')
  elseif M.exists(bard.bufnr) and not M.visible(bard.bufnr) then
    vim.cmd('tabnew nvim-bard')
  else
    M.open("tabnew")
  end
end

function M.exists(bufnr)
  return bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr)
end

function M.visible(bufnr)
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(winid) == bufnr then
      return true
    end
  end
end

function M.reload(bufnr)
  vim.api.nvim_buf_call(bufnr, function()
      vim.cmd('normal gg')
    end)
  Signs.del(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  Signs.set_for_lines(bufnr, 1, 1, "question")
  line_count = 1
end

function M.mappings(bufnr)
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true, buffer = bufnr }
  map("n", send_bard, function() M.get_query(bard.bufnr) end, opts)
  map("n", new_chat, function() M.reload(bard.bufnr) end, opts)
end

function M.open(type)
  vim.cmd(string.format('%s nvim-bard', type))
  buf_infos()
  vim.api.nvim_buf_call(bard.bufnr, function()
    for i, j in pairs(buffer_options) do
      vim.opt[i] = j
    end
    vim.cmd('hi SignColumn ctermbg=NONE guibg=NONE')
    vim.cmd('hi link markdownError NONE')
  end)
  Signs.set_for_lines(bard.bufnr, line_count, line_count, "question")
  M.mappings(bard.bufnr)
end

function M.get_query(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, line_count - 1, -1, false)
  local function check_first_line()
    if line_count == 1 then
      Signs.del(bufnr)
      return 0
    else
      return line_count
    end
  end
  Signs.set_for_lines(bufnr, 1 + check_first_line(), #lines + check_first_line(), "question")
  if line_count == 1 then
    if not Bard.check_api_key() then
      do return end
    else
      vim.defer_fn(function() Bard.load() end, 0)
    end
  end

  line_count = line_count + #lines

  local query  = table.concat(lines, "\n")
  if query == "" or nil then
    print("[nvim-bard] Can't send empty query")
    do return end
  else
  vim.defer_fn(function()
    local result = Bard.ask(query)
    M.write_answer(result, bufnr)
  end, 0)
  end
end

function M.write_answer(lines, bufnr)
  vim.api.nvim_buf_set_lines(bufnr, line_count, -1, false, { "" })
  Signs.set_for_lines(bufnr, line_count + 1, #lines + line_count, "bard")
  vim.api.nvim_buf_set_lines(bufnr, line_count + 1, -1, false, lines)
  line_count = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, line_count + 1, -1, false, { "", "" })
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd('normal G')
  end)
  line_count = vim.api.nvim_buf_line_count(bufnr)
  Signs.set_for_lines(bufnr, line_count, line_count, "question")
end

return M
