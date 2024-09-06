---@class kanban.board.options
---@field data kanban.api.board
---@field source kanban.source

---@class kanban.board
---@field new fun(opts: kanban.board.options): kanban.board
---@field tabpage number
---@field buf number
---@field title string
---@field lists kanban.list[]
---@field focused_list number
---@field source kanban.source
local M = {}
M.__index = M

local guicursor

function M:calculate_dimensions(total)
  local function height()
    -- TODO: should consider enabled winbar. tabline etc
    return vim.o.lines - 5
  end

  local width = math.floor(vim.o.columns / total)
  local remaining = vim.o.columns % total

  local function widths()
    local w = {}
    for i = 1, total do
      -- TODO: maybe add border config? -> -2 variable
      w[i] = width - 2
      if i >= total - remaining + 1 then
        w[i] = w[i] + 1
      end
    end
    return w
  end

  local function cols()
    local c = {}
    for i = 1, total do
      c[i] = (i - 1) * width
      if i >= total - remaining + 1 then
        c[i] = c[i] + (i - (total - remaining + 1))
      end
    end
    return c
  end

  return {
    height = height(),
    widths = widths(),
    cols = cols(),
  }
end

function M:display()
  vim.cmd.tabnew()
  self.tabpage = vim.api.nvim_get_current_tabpage()
  self.buf = vim.api.nvim_get_current_buf()
  vim.bo[self.buf].bufhidden = "delete"
  vim.bo[self.buf].buflisted = false
  guicursor = vim.go.guicursor
  vim.go.guicursor = "a:KanbanCursor"

  local dimensions = self:calculate_dimensions(#self.lists)

  local win = vim.api.nvim_get_current_win()
  local winbar_padding = math.floor((vim.o.columns - #self.title) / 2)
  vim.wo[win].winbar = (" "):rep(winbar_padding) .. self.title

  for i, list in ipairs(self.lists) do
    list:display {
      height = dimensions.height,
      width = dimensions.widths[i],
      col = dimensions.cols[i],
    }
  end

  if self.focused_list then
    self.lists[self.focused_list]:focus()
  end
end

---@param direction 1|-1
function M:focus_list(direction)
  self.lists[self.focused_list]:unfocus()
  self.focused_list = self.focused_list + direction
  if self.focused_list < 1 then
    self.focused_list = #self.lists
  elseif self.focused_list > #self.lists then
    self.focused_list = 1
  end
  self.lists[self.focused_list]:focus()
end

function M:destroy()
  for _, list in ipairs(self.lists) do
    list:destroy()
  end

  vim.go.guicursor = guicursor
  vim.cmd.tabclose()
end

function M:update_lists(lists)
  for _, list in ipairs(self.lists) do
    if vim.tbl_contains(lists, list.title) then
      list:update(self.source.tasks_by_list(list.title))
    end
  end
end

function M.new(opts)
  local board = setmetatable({
    title = opts.data.title,
    lists = {},
    source = opts.source,
  }, M) --[[@as kanban.board]]

  if opts.data.lists[1] then
    board.focused_list = 1
  end

  local initial_focus = opts.source.config.initial_focus and opts.source.config.initial_focus()

  local List = require "kanban.list"
  for i, list in ipairs(opts.data.lists) do
    if initial_focus == i or initial_focus == list.title then
      board.focused_list = i
    end

    board.lists[i] = List.new {
      index = i,
      board = board,
      data = list,
    }
  end

  local normal = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
  for name, hl in pairs(opts.data.labels) do
    vim.api.nvim_set_hl(0, "KanbanLabel" .. name, { fg = hl.fg, bg = hl.bg })
  end
  for name, hl in pairs(require("kanban.config").highlights) do
    vim.api.nvim_set_hl(0, "Kanban" .. name, { fg = hl.fg, bg = normal.bg })
  end
  vim.api.nvim_set_hl(0, "KanbanCursor", { blend = 100, reverse = true })

  return board
end

return M
