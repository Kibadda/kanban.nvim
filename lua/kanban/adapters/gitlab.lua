local M = {}

function M.config()
  return require("kanban.config").adapters.gitlab
end

local function request(url)
  local curl = require "kanban.curl"

  local gitlab_config = M.config()

  if not gitlab_config then
    return
  end

  return curl.request("GET", vim.env[gitlab_config.project] .. "/" .. url, {
    ["PRIVATE-TOKEN"] = vim.env[gitlab_config.token],
  })
end

local function board()
  local boards = request "boards"

  if not boards then
    return
  end

  local gitlab_config = M.config()
  local boardId = gitlab_config and gitlab_config.boardId

  if boardId then
    for _, b in ipairs(boards) do
      if b.id == boardId then
        return b
      end
    end
  elseif boards[1] then
    return boards[1]
  end
end

local function labels()
  local ls = {}

  for _, label in ipairs(request "labels" or {}) do
    ls[label.name] = {
      fg = label.text_color,
      bg = label.color,
    }
  end

  return ls
end

local function tasks(lists)
  local mapping = {}

  for _, task in ipairs(request "issues" or {}) do
    local list = "Open"
    local ls = {}

    for _, label in ipairs(task.labels) do
      if vim.list_contains(lists, label) then
        list = label
      else
        table.insert(ls, label)
      end
    end

    if task.state == "closed" then
      list = "Closed"
    end

    mapping[list] = mapping[list] or {}
    table.insert(mapping[list], {
      title = task.title,
      labels = ls,
    })
  end

  for i, list in ipairs(lists) do
    lists[i] = {
      title = list,
      tasks = mapping[list] or {},
    }
  end
end

---@return kanban.api.board?
function M.get()
  local board_data = board()

  if not board_data then
    return
  end

  local lists = vim.tbl_map(function(list)
    return list.label.name
  end, board_data.lists)
  table.insert(lists, 1, "Open")
  table.insert(lists, "Closed")

  tasks(lists)

  return {
    title = board_data.name,
    lists = lists,
    labels = labels(),
  }
end

return M
