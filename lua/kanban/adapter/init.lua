---@class kanban.adapter
---@field data fun(): table
---@field config fun(): table

local M = {}

---@param name string
---@return kanban.adapter
function M.get(name)
  local adapter = require("kanban.adapter." .. name)
  return adapter
end

return M
