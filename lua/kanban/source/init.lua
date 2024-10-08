---@class kanban.source
---@field data fun(): table
---@field config kanban.config.source
---@field move_task_to_list fun(task: kanban.task, list: string): boolean
---@field tasks_by_list fun(list: string): table
---@field add_task fun(title: string, labels: string[]): boolean
---@field edit_task fun(task: kanban.task): boolean
---@field delete_task fun(task: kanban.task): boolean

local M = {}

---@param name? string
---@return kanban.source?
function M.get(name)
  ---@param source kanban.config.source
  ---@return kanban.source?
  local function get(source)
    local ok, api = pcall(require, "kanban.source." .. source.type)

    if ok then
      api.config = source
      return api
    end
  end

  local sources = require("kanban.config").sources

  local default

  for _, source in ipairs(sources) do
    if source.name == name then
      return get(source)
    end

    if source.default then
      default = source
    end
  end

  if default then
    return get(default)
  end

  if #sources == 1 then
    return get(sources[1])
  end
end

return M
