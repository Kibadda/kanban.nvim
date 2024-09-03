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

function M.lists()
  local boards = request "boards"

  if not boards then
    return
  end

  local gitlab_config = M.config()
  local boardId = gitlab_config and gitlab_config.boardId

  local board
  if #boards == 1 or not boardId then
    board = boards[1]
  else
    for _, b in ipairs(boards) do
      if b.id == boardId then
        board = b
        break
      end
    end
  end

  if not board then
    return
  end

  local labels = {}

  for _, l in ipairs(board.lists) do
    table.insert(labels, l.label.name)
  end

  table.insert(labels, 1, "Open")
  table.insert(labels, "Closed")

  return labels
end

function M.tasks()
  local issues = request "issues"

  if not issues then
    return {}
  end

  local lists = M.lists()

  if not lists then
    return {}
  end

  local tasks = {}

  for _, i in ipairs(issues) do
    local list = "Open"
    local labels = {}

    for _, l in ipairs(i.labels) do
      if vim.tbl_contains(lists, l) then
        list = l
      else
        table.insert(labels, l)
      end
    end

    if i.state == "closed" then
      list = "Closed"
    end

    table.insert(tasks, {
      id = i.iid,
      title = i.title,
      list = list,
      labels = labels,
      -- description = i.description ~= vim.NIL and i.description or nil,
      -- time = i.time_stats.total_time_spent ~= vim.NIL and math.floor(i.time_stats.total_time_spent / 60) or 0,
    })
  end

  return tasks
end

return M
