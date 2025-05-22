local M = {}

--- validate given config
---@param config kanban.internalconfig
---@return boolean
---@return string[]
function M.validate(config)
  local errors = {}

  --- small wrapper around vim.validate
  ---@param name string
  ---@param value any
  ---@param types any|any[]
  ---@param optional? boolean
  ---@return boolean
  local function validate(name, value, types, optional)
    local ok, err = pcall(vim.validate, name, value, types, optional)

    if not ok then
      table.insert(errors, err)
    end

    return ok
  end

  if validate("kanban.highlights", config.highlights, "table", true) and config.highlights then
    validate("kanban.highlights.ListTitle", config.highlights.ListTitle, "table", true)
    validate("kanban.highlights.ListBorder", config.highlights.ListBorder, "table", true)
    validate("kanban.highlights.ListBorderFocused", config.highlights.ListBorderFocused, "table", true)
    validate("kanban.highlights.TaskBorder", config.highlights.TaskBorder, "table", true)
    validate("kanban.highlights.TaskBorderFocused", config.highlights.TaskBorderFocused, "table", true)
  end

  if validate("kanban.sources", config.sources, "table", true) and config.sources then
    for i, source in ipairs(config.sources) do
      validate("kanban.sources." .. i .. ".name", source.type, "string")
      validate("kanban.sources." .. i .. ".data", source.data, "table")
      validate("kanban.sources." .. i .. ".default", source.default, "boolean", true)
      validate("kanban.sources." .. i .. ".initial_focus", source.initial_focus, "function", true)

      if validate("kanban.sources." .. i .. ".type", source.type, "string") then
        if source.type == "gitlab" then
          validate("kanban.sources." .. i .. ".data.token", source.data.token, "string")
          validate("kanban.sources." .. i .. ".data.project", source.data.project, "string")
          validate("kanban.sources." .. i .. ".data.boardId", source.data.boardId, "number", true)
        end
      end
    end
  end

  return #errors == 0, errors
end

return M
