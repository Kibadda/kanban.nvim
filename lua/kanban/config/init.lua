---@class kanban.config.highlights
---@field Title? vim.api.keyset.highlight
---@field Border? vim.api.keyset.highlight
---@field BorderFocused? vim.api.keyset.highlight

---@class kanban.config.adapters.gitlab
---@field token string
---@field project string
---@field boardId? integer
---@field default? boolean
---@field initial_focus? fun(name: string): boolean

---@class kanban.config.adapters
---@field gitlab? kanban.config.adapters.gitlab

---@class kanban.config
---@field adapters? kanban.config.adapters
---@field highlights? kanban.config.highlights

---@class kanban.internalconfig
---@field adapters kanban.config.adapters
local KanbanDefaultConfig = {
  ---@type string?
  adapter = nil,
  adapters = {},
  highlights = {
    ListTitle = { fg = "#89B482" },
    ListBorder = { fg = "#D4BE98" },
    ListBorderFocused = { fg = "#EA6962" },
    TaskBorder = { fg = "#D4BE98" },
    TaskBorderFocused = { fg = "#EA6962" },
  },
}

---@type kanban.config | (fun(): kanban.config) | nil
vim.g.kanban = vim.g.kanban

---@type kanban.config
local opts = type(vim.g.kanban) == "function" and vim.g.kanban() or vim.g.kanban or {}

---@type kanban.internalconfig
local KanbanConfig = vim.tbl_deep_extend("force", {}, KanbanDefaultConfig, opts)

local check = require "kanban.config.check"
local ok, err = check.validate(KanbanConfig)
if not ok then
  vim.notify("kanban: " .. err, vim.log.levels.ERROR)
end

return KanbanConfig
