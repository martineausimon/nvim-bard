local Config = require('nvim-bard.config')
local Signs = require('nvim-bard.signs')
local Bard = require('nvim-bard.bard')

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local send_bard = Config.options.mappings.send_bard
local new_chat = Config.options.mappings.new_chat
local hide_bard = Config.options.mappings.hide_bard
local buffer_options = Config.options.options.buffer_options
local top_popup_border = Config.options.options.ui.bard.border
local bottom_popup_border = Config.options.options.ui.question.border

local layout, top_popup, bottom_popup, bard_status

local M = {}

function M.toggle()
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
    border = top_popup_border
  })

  bottom_popup = Popup({
    enter = true,
    border = bottom_popup_border
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
    vim.api.nvim_buf_call(top_popup.bufnr, function()
      for i, j in pairs(buffer_options) do
        vim.opt[i] = j
      end
      vim.cmd('hi SignColumn ctermbg=NONE guibg=NONE')
      vim.cmd('hi link markdownError NONE')
    end)
  end)

  bottom_popup:on(event.BufWinEnter, function()
    vim.cmd('startinsert')
  end)

  bottom_popup:on(event.BufWipeout, function()
    bard_status = nil
  end)

  local bard_hide = function()
    layout:hide()
    bard_status = "hidden"
  end

  local map = vim.keymap.set
  local opts = { noremap = true, silent = true, buffer = bottom_popup.bufnr }
  map("n", new_chat, function()
    vim.api.nvim_buf_call(top_popup.bufnr, function()
      vim.cmd('normal gg')
    end)
    Signs.del(top_popup.bufnr)
    vim.api.nvim_buf_set_lines(bottom_popup.bufnr, 0, -1, false, {})
    vim.api.nvim_buf_set_lines(top_popup.bufnr, 0, -1, false, {})
  end, opts)

  map("n", send_bard, function() M.get_content() end, opts)

  if type(hide_bard) == "string" then
    map('n', hide_bard, bard_hide, opts)
  elseif type(hide_bard) == "table" then
    for _, key in ipairs(hide_bard) do
        map('n', key, bard_hide, opts)
    end
  end

  layout:mount()
end

function M.get_content()
  local lines = vim.api.nvim_buf_get_lines(bottom_popup.bufnr, 0, -1, false)
  if vim.api.nvim_buf_line_count(top_popup.bufnr) == 1 then
    if not Bard.check_api_key() then
      do return end
    end
    vim.defer_fn(function() Bard.load() end, 0)
  end
  local query  = table.concat(lines, "\n")
  if query == "" or nil then
    print("[nvim-bard] Can't send empty query")
    do return end
  else
    M.write_top_buffer(lines, "question")
    vim.defer_fn(function()
      local result = Bard.ask(query)
      M.write_top_buffer(result, "bard")
    end, 0)
  end
end

function M.write_top_buffer(lines, type)

  local buf = top_popup.bufnr

  local line_count = vim.api.nvim_buf_line_count(buf)

  local function check_first_line()
    if line_count == 1 then return 0 else return line_count end
  end

  Signs.set_for_lines(buf, 1 + check_first_line(), #lines + check_first_line(), type)

  table.insert(lines, "")
  vim.api.nvim_buf_set_lines(buf, check_first_line(), -1, false, lines)
  vim.api.nvim_buf_set_lines(bottom_popup.bufnr, 0, -1, false, {})
  vim.api.nvim_buf_call(top_popup.bufnr, function()
    vim.cmd('normal G')
  end)
end

return M
