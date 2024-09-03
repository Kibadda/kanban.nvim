local M = {
  lists = {},
}

local shown = false
---@type integer?
local tabpage = nil

function M.toggle()
  if shown then
    M.close()
  else
    M.show()
  end
end

function M.close()
  if not tabpage or not vim.api.nvim_tabpage_is_valid(tabpage) then
    tabpage = nil
    return
  end

  M.destroy()

  vim.cmd.tabclose()

  tabpage = nil
  shown = false
end

function M.show()
  if not tabpage or not vim.api.nvim_tabpage_is_valid(tabpage) then
    tabpage = M.create()
  end

  vim.api.nvim_set_current_tabpage(tabpage)

  shown = true
end

function M.destroy()
  for _, list in ipairs(M.lists) do
    vim.api.nvim_win_close(list, true)
  end

  M.lists = {}
end

function M.create()
  vim.cmd.tabnew()
  local tab = vim.api.nvim_get_current_tabpage()
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "delete"
  vim.bo[buf].buflisted = false

  local gitlab = require "kanban.adapters.gitlab"
  local config = gitlab.config()

  local list_names = gitlab.lists()

  if not list_names then
    return tab
  end

  local tasks = {}
  for _, task in ipairs(gitlab.tasks() or {}) do
    tasks[task.list] = tasks[task.list] or {}
    table.insert(tasks[task.list], task)
  end

  local amount = #list_names
  local height = vim.o.lines - 5
  local width = math.floor(vim.o.columns / amount)
  local remaining = vim.o.columns % amount

  local default_win
  local win
  for i, list_name in ipairs(list_names) do
    local col_offset = 0
    local width_offset = 0
    if i >= amount - remaining + 1 then
      col_offset = (i - (amount - remaining + 1))
      width_offset = 1
    end

    local b = vim.api.nvim_create_buf(false, true)
    local w = vim.api.nvim_open_win(b, false, {
      relative = "editor",
      border = "single",
      title = " " .. list_name .. " ",
      title_pos = "center",
      height = height,
      width = width + width_offset - 2,
      row = 1,
      col = (i - 1) * width + col_offset,
      style = "minimal",
    })

    table.insert(M.lists, w)

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = b, desc = desc })
    end

    map("q", function()
      M.close()
    end, "Close")

    map("h", function()
      vim.api.nvim_set_current_win(M.lists[i > 1 and i - 1 or #M.lists])
    end, "Focus previous list")

    map("l", function()
      vim.api.nvim_set_current_win(M.lists[i < #M.lists and i + 1 or 1])
    end, "Focus next list")

    local lines = {}
    for _, task in ipairs(tasks[list_name] or {}) do
      table.insert(lines, task.title)
    end

    vim.api.nvim_buf_set_lines(b, 0, -1, false, lines)

    if not default_win then
      default_win = w
    end
    if config.current and config.current(list_name) then
      win = w
    end
  end

  vim.api.nvim_tabpage_set_win(tab, win or default_win)

  return tab
end

return M
