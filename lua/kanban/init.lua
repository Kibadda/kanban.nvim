local M = {}

---@class kanban.api.board
---@field title string
---@field labels table<string, { fg: string, bg: string }>
---@field lists kanban.api.list[]

---@class kanban.api.list
---@field title string
---@field tasks kanban.api.task[]

---@class kanban.api.task
---@field title string
---@field labels string[]

---@param data table
function M.open(data)
  local cmd = table.remove(data.fargs, 1)

  local config = require "kanban.config"

  cmd = cmd or config.adapter

  if not config.adapters[cmd] then
    vim.notify("adapter '" .. cmd .. "' not found", vim.log.levels.WARN)
    return
  end

  local gitlab = require "kanban.adapters.gitlab"
  local board = gitlab.get()
  local initial_focus = gitlab.config().initial_focus

  if not board then
    return
  end

  -- TODO: add title of board
  local Board = require("kanban.board").new {
    data = board,
    initial_focus = initial_focus,
  }
  Board:display()
end

---@param cmdline string
---@return string[]?
function M.complete(cmdline)
  local cmd = cmdline:match "^Kanban%s+(.*)$"

  if cmd then
    local complete = vim.tbl_filter(function(command)
      return string.find(command, "^" .. cmd) ~= nil
    end, vim.tbl_keys(require("kanban.config").adapters))

    table.sort(complete)

    return complete
  end
end

return M
