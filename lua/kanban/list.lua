---@class kanban.list.options
---@field index number
---@field board kanban.board
---@field data kanban.api.list

---@class kanban.list.dimensions
---@field height number
---@field width number
---@field col number

---@class kanban.list
---@field new fun(opts: kanban.list.options): kanban.list
---@field display fun(self: kanban.list, opts: kanban.list.dimensions)
---@field dimensions kanban.list.dimensions
---@field tasks kanban.task[]
---@field focused_task number
---@field buf number
---@field win number
---@field board kanban.board
---@field index number
---@field title string
local M = {}
M.__index = M

function M:create_window()
  self.buf = vim.api.nvim_create_buf(false, true)
  self.win = vim.api.nvim_open_win(self.buf, false, {
    relative = "editor",
    border = "single",
    title = " " .. self.title .. " ",
    title_pos = "center",
    height = self.dimensions.height,
    width = self.dimensions.width,
    row = 1,
    col = self.dimensions.col,
    style = "minimal",
  })
  vim.wo[self.win].winhighlight = "FloatTitle:KanbanListTitle,FloatBorder:KanbanListBorder"
end

function M:set_keymaps()
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = self.buf, desc = desc })
  end

  map("q", function()
    self.board:destroy()
  end, "Close")

  map("h", function()
    self.board:focus_list(-1)
  end, "Focus previous list")

  map("l", function()
    self.board:focus_list(1)
  end, "Focus previous list")

  map("c", function()
    self:add_task()
  end)
end

function M:add_task()
  self.board:restore_cursor()
  local title
  vim.ui.input({ prompt = "Title: " }, function(input)
    title = input
  end)

  if not title or title == "" then
    self.board:set_cursor()
    return
  end

  local labels
  vim.ui.input({ prompt = "Labels: " }, function(input)
    labels = vim.split(input or "", ",")
  end)

  self.board:set_cursor()

  table.insert(labels, self.title)

  if self.board.source.add_task(title, labels) then
    vim.schedule(function()
      self.board:update_lists { self.title }
      self:focus()
    end)
  end
end

function M:display_tasks()
  local row = 0
  for _, task in ipairs(self.tasks) do
    task:display {
      width = self.dimensions.width,
      row = row,
    }
    row = row + task.height
  end
end

function M:display(opts)
  self.dimensions = opts
  self:create_window()
  self:display_tasks()
  self:set_keymaps()
end

function M:focus()
  vim.api.nvim_set_current_win(self.win)

  if self.focused_task then
    self.tasks[self.focused_task]:focus()
  end

  vim.wo[self.win].winhighlight = "FloatTitle:KanbanListTitle,FloatBorder:KanbanListBorderFocused"
end

function M:unfocus()
  vim.wo[self.win].winhighlight = "FloatTitle:KanbanListTitle,FloatBorder:KanbanListBorder"
  if self.tasks[self.focused_task] then
    vim.wo[self.tasks[self.focused_task].win].winhighlight = "FloatBorder:KanbanTaskBorder"
  end
end

---@param tasks kanban.api.task[]
function M:update(tasks)
  for _, task in ipairs(self.tasks) do
    task:destroy()
  end

  self.tasks = {}
  local Task = require "kanban.task"
  for i, task in ipairs(tasks) do
    self.tasks[i] = Task.new {
      index = i,
      list = self,
      data = task,
    }
  end

  if not self.tasks[1] then
    self.focused_task = nil
  elseif not self.tasks[self.focused_task] then
    self.focused_task = #self.tasks
  end

  self:display_tasks()
end

---@param direction 1|-1
function M:focus_task(direction)
  self.tasks[self.focused_task]:unfocus()
  self.focused_task = self.focused_task + direction
  if self.focused_task < 1 then
    self.focused_task = #self.tasks
  elseif self.focused_task > #self.tasks then
    self.focused_task = 1
  end
  self.tasks[self.focused_task]:focus()
end

function M:destroy()
  for _, task in ipairs(self.tasks) do
    task:destroy()
  end

  if vim.api.nvim_buf_is_valid(self.buf) then
    vim.api.nvim_buf_delete(self.buf, { force = true })
  end
  if vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_close(self.win, true)
  end
end

function M.new(opts)
  local list = setmetatable({
    title = opts.data.title,
    index = opts.index,
    board = opts.board,
    tasks = {},
  }, M) --[[@as kanban.list]]

  local Task = require "kanban.task"
  for i, task in ipairs(opts.data.tasks) do
    list.tasks[i] = Task.new {
      index = i,
      list = list,
      data = task,
    }
  end

  if list.tasks[1] then
    list.focused_task = 1
  end

  return list
end

return M
