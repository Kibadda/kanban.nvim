local M = {}

---@param data table
function M.open(data)
  local cmd = table.remove(data.fargs, 1)

  local config = require "kanban.config"

  cmd = cmd or config.adapter

  if not config.adapters[cmd] then
    vim.notify("adapter '" .. cmd .. "' not found", vim.log.levels.WARN)
    return
  end

  local windows = require "kanban.windows"

  windows.show()
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
