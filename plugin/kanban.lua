if vim.g.loaded_kanban then
  return
end

vim.g.loaded_kanban = 1

vim.api.nvim_create_user_command("Kanban", function(data)
  require("kanban").open(data)
end, {
  bang = false,
  bar = false,
  desc = "Kanban board",
  nargs = "?",
  complete = function(_, cmdline, _)
    return require("kanban").complete(cmdline)
  end,
})
