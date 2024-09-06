---@class kanban.config.highlights
---@field ListTitle? vim.api.keyset.highlight
---@field ListBorder? vim.api.keyset.highlight
---@field ListBorderFocused? vim.api.keyset.highlight
---@field TaskBorder? vim.api.keyset.highlight
---@field TaskBorderFocused? vim.api.keyset.highlight

---@class kanban.config.source
---@field type "gitlab"
---@field name string
---@field data table
---@field default? boolean
---@field initial_focus? fun(): boolean

---@class kanban.config
---@field sources kanban.config.source[]
---@field highlights? kanban.config.highlights

---@class kanban.internalconfig
---@field sources kanban.config.source[]
local KanbanDefaultConfig = {
  sources = {},
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
