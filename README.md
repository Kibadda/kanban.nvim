# kanban.nvim

## Configuration
To change the default configuration, set `vim.g.kanban`.

Default config:
```lua
vim.g.kanban = {
  adapter = nil,
  adapters = {},
  highlights = {
    KanbanBorder = { fg = "#D4BE98" },
    KanbanBorderCurrent = { fg = "#89B482" },
    KanbanTitle = { fg = "#EA6962" },
    KanbanLabel = { fg = "#7DAEA3" },
  },
}
```

## Usage
