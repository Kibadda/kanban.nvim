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
    sources = { config.sources, "table", true },
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

  for i, source in ipairs(config.sources) do
    ok, err = validate("kanban.sources." .. i, {
      type = { source.type, "string" },
      name = { source.name, "string" },
      data = { source.data, "table" },
      default = { source.default, "boolean", true },
      initial_focus = { source.initial_focus, "function", true },
    })
    if not ok then
      return false, err
    end

    if source.type == "gitlab" then
      ok, err = validate("kanban.sources." .. i .. ".data", {
        token = { source.data.token, "string" },
        project = { source.data.project, "string" },
        boardId = { source.data.boardId, "number", true },
      })
      if not ok then
        return false, err
      end
    end
  end

  return true
end

return M
