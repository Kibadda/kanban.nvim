---@class kanban.task.options
---@field index number
---@field list kanban.list
---@field data kanban.api.task

---@class kanban.task.dimensions
---@field width number
---@field row number

---@class kanban.task
---@field new fun(opts: kanban.task.options): kanban.task
---@field display fun(self: kanban.task, opts: kanban.task.dimensions)
---@field create_window fun(self: kanban.task, opts: kanban.task.dimensions)
---@field buf number
---@field win number
---@field height number
---@field list kanban.list
---@field title string
---@field labels string[]
---@field api_url string
local M = {}
M.__index = M

function M:set_keymaps()
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = self.buf, desc = desc })
  end

  map("q", function()
    self.list.board:destroy()
  end)

  map("h", function()
    self.list.board:focus_list(-1)
  end)

  map("l", function()
    self.list.board:focus_list(1)
  end)

  map("j", function()
    self.list:focus_task(1)
  end)

  map("k", function()
    self.list:focus_task(-1)
  end)

  map("c", function()
    self.list:add_task()
  end)

  map("H", function()
    local list = self.list.board.lists[self.list.board:get_list_index(-1)]
    if self.list.board.source.move_task_to_list(self, list.title) then
      vim.schedule(function()
        self.list.board:update_lists { self.list.title, list.title }
        self.list:focus()
      end)
    end
  end)

  map("L", function()
    local list = self.list.board.lists[self.list.board:get_list_index(1)]
    if self.list.board.source.move_task_to_list(self, list.title) then
      vim.schedule(function()
        self.list.board:update_lists { self.list.title, list.title }
        self.list:focus()
      end)
    end
  end)

  map("m", function()
    vim.ui.select(
      vim.tbl_map(function(list)
        return list.title
      end, self.list.board.lists),
      {
        prompt = "Move to: ",
      },
      function(choice)
        if not choice then
          return
        end

        if self.list.board.source.move_task_to_list(self, choice) then
          vim.schedule(function()
            self.list.board:update_lists { self.list.title, choice }
            self.list:focus()
          end)
        end
      end
    )
  end)
end

function M:calculate_lines(width)
  local lines = {}
  local current_line = ""

  for word in vim.gsplit(self.title, " ", { trimempty = true }) do
    if current_line == "" and #word > width - 2 then
      table.insert(lines, " " .. word:sub(1, width - 2))
      current_line = " " .. word:sub(width - 1)
    elseif #current_line + #" " + #word > width - 2 then
      table.insert(lines, current_line)
      current_line = " " .. word
    else
      current_line = current_line .. " " .. word
    end
  end

  if current_line ~= "" then
    table.insert(lines, current_line)
  end

  return lines
end

function M:display(opts)
  local ns = vim.api.nvim_create_namespace "Kanban"
  local lines = self:calculate_lines(opts.width - 2)
  if self.labels[1] then
    table.insert(lines, "")
  end

  self.height = #lines + 2
  self.buf = vim.api.nvim_create_buf(false, true)
  self.win = vim.api.nvim_open_win(self.buf, false, {
    relative = "win",
    win = self.list.win,
    border = "single",
    height = self.height - 2,
    width = opts.width - 2,
    row = opts.row,
    col = 0,
    style = "minimal",
  })
  vim.wo[self.win].winhighlight = "FloatTitle:KanbanTaskTitle,FloatBorder:KanbanTaskBorder"

  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
  for _, label in ipairs(self.labels) do
    vim.api.nvim_buf_set_extmark(self.buf, ns, #lines - 1, 0, {
      virt_text = { { " " .. label .. " ", "KanbanLabel" .. label } },
    })
  end

  self:set_keymaps()
end

function M:focus()
  vim.api.nvim_set_current_win(self.win)
  vim.wo[self.win].winhighlight = "FloatBorder:KanbanTaskBorderFocused"
end

function M:unfocus()
  vim.wo[self.win].winhighlight = "FloatBorder:KanbanTaskBorder"
end

function M:destroy()
  if vim.api.nvim_buf_is_valid(self.buf) then
    vim.api.nvim_buf_delete(self.buf, { force = true })
  end
  if vim.api.nvim_win_is_valid(self.win) then
    vim.api.nvim_win_close(self.win, true)
  end
end

function M.new(opts)
  return setmetatable({
    title = opts.data.title,
    labels = opts.data.labels,
    index = opts.index,
    list = opts.list,
    api_url = opts.data.api_url,
  }, M) --[[@as kanban.task]]
end

return M
