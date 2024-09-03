local M = {}

--- small wrapper around vim.validate
---@param path string
---@param tbl table
---@return boolean
---@return string?
local function validate(path, tbl)
  local prefix = "invalid config: "
  local ok, err = pcall(vim.validate, tbl)
  return ok or false, prefix .. (err and path .. "." .. err or path)
end

--- validate given config
---@param config kanban.internalconfig
---@return boolean
---@return string?
function M.validate(config)
  local ok, err

  ok, err = validate("kanban", {
    highlights = { config.highlights, "table", true },
    adapters = { config.adapters, "table", true },
  })
  if not ok then
    return false, err
  end

  ok, err = validate("kanban.highlights", {
    KanbanBorder = { config.highlights.KanbanBorder, "table", true },
    KanbanBorderCurrent = { config.highlights.KanbanBorderCurrent, "table", true },
    KanbanTitle = { config.highlights.KanbanTitle, "table", true },
    KanbanLabel = { config.highlights.KanbanTime, "table", true },
  })
  if not ok then
    return false, err
  end

  if config.adapters.gitlab then
    ok, err = validate("kanban.adapters.gitlab", {
      token = { config.adapters.gitlab.token, "string" },
      project = { config.adapters.gitlab.project, "string" },
      labels = { config.adapters.gitlab.labels, "table", true },
      default = { config.adapters.gitlab.default, "boolean", true },
    })
    if not ok then
      return false, err
    end

    config.adapter = "gitlab"
  else
    return false, "invalid config: kanban.adapters must have at least one adapter configured"
  end

  return true
end

return M
