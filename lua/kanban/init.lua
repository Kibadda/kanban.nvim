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
---@field api_url string

---@param data table
function M.open(data)
  local cmd = table.remove(data.fargs, 1)

  local source = require("kanban.source").get(cmd)

  if not source then
    vim.notify("source '" .. cmd .. "' not found", vim.log.levels.WARN)
    return
  end

  local board = source.data()

  if not board then
    return
  end

  local Board = require("kanban.board").new {
    data = board,
    source = source,
  }
  Board:display()
end

---@param cmdline string
---@return string[]?
function M.complete(cmdline)
  local cmd = cmdline:match "^Ka?n?b?a?n?%s+(.*)$"

  if cmd then
    local complete = vim.tbl_filter(
      function(command)
        return string.find(command, "^" .. cmd) ~= nil
      end,
      vim.tbl_map(function(source)
        return source.name
      end, require("kanban.config").sources)
    )

    table.sort(complete)

    return complete
  end
end

return M
