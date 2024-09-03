---@class kanban.config.highlights
---@field KanbanBorder? vim.api.keyset.highlight
---@field KanbanBorderCurrent? vim.api.keyset.highlight
---@field KanbanTitle? vim.api.keyset.highlight
---@field KanbanLabel? vim.api.keyset.highlight

---@class kanban.config.adapters.gitlab
---@field token string
---@field project string
---@field boardId? integer
---@field labels? string[]
---@field default? boolean
---@field current? fun(name: string): string

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
    KanbanBorder = { fg = "#D4BE98" },
    KanbanBorderCurrent = { fg = "#89B482" },
    KanbanTitle = { fg = "#EA6962" },
    KanbanLabel = { fg = "#7DAEA3" },
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
