---@class kanban.adapter
---@field data fun(): table
---@field config fun(): table
---@field move_task_to_list fun(task: kanban.task, list: string)

local M = {}

---@param name string
---@return kanban.adapter
function M.get(name)
  local adapter = require("kanban.adapter." .. name)
  return adapter
end

return M
