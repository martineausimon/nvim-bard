local Config = require('nvim-bard.config')

local question = Config.options.options.ui.question.signs
local bard = Config.options.options.ui.bard.signs
local sign = vim.fn.sign_define
local styles = {
  double  = { "║", "╚" },
  none    = { " ", " " },
  rounded = { "│", "╰" },
  single  = { "│", "└" },
  solid   = { "┃", "┗" },
}

local M = {}

sign('first_line_question', { text = question.sign,             texthl = question.hi })
sign('lines_question',      { text = styles[question.style][1], texthl = question.hi })
sign('last_line_question',  { text = styles[question.style][2], texthl = question.hi })
sign('first_line_bard',     { text = bard.sign,                 texthl = bard.hi     })
sign('lines_bard',          { text = styles[bard.style][1],     texthl = bard.hi     })
sign('last_line_bard',      { text = styles[bard.style][2],     texthl = bard.hi     })

function M.set(name, bufnr, line)
  pcall(vim.fn.sign_place, 0, "nvim_bard_ns", name, bufnr, { lnum = line })
end

function M.del(bufnr)
  pcall(vim.fn.sign_unplace, "nvim_bard_ns", { buffer = bufnr })
end

function M.set_for_lines(bufnr, start_line, end_line, type)
  if start_line == end_line or end_line < start_line then
    M.set('first_line_' .. type, bufnr, start_line)
  else
    M.set('first_line_' .. type, bufnr, start_line)
    M.set('last_line_' .. type, bufnr, end_line)
  end
  if start_line + 1 < end_line then
    for j = start_line + 1, end_line - 1, 1 do
      M.set("lines_" .. type, bufnr, j)
    end
  end
end

return M
