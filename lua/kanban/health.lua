local M = {}

function M.check()
  vim.health.start "checking config"

  local config = require "kanban.config"
  local ok, err = require("kanban.config.check").validate(config)

  if ok then
    vim.health.ok "no errors found in config"
  else
    vim.health.error(err or "" .. vim.g.kanban and "" or " This looks like a plugin bug!")
  end
end

return M
