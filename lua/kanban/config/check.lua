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
    ListTitle = { config.highlights.ListTitle, "table", true },
    ListBorder = { config.highlights.ListBorder, "table", true },
    ListBorderFocused = { config.highlights.ListBorderFocused, "table", true },
    TaskBorder = { config.highlights.TaskBorder, "table", true },
    TaskBorderFocused = { config.highlights.TaskBorderFocused, "table", true },
  })
  if not ok then
    return false, err
  end

  if config.adapters.gitlab then
    ok, err = validate("kanban.adapters.gitlab", {
      token = { config.adapters.gitlab.token, "string" },
      project = { config.adapters.gitlab.project, "string" },
      boardId = { config.adapters.gitlab.boardId, "number", true },
      default = { config.adapters.gitlab.default, "boolean", true },
      initial_focus = { config.adapters.gitlab.initial_focus, "function", true },
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
