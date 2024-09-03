local M = {}

local curl = require "plenary.curl"

---@param method string
---@param url string
---@param headers table
---@param data? table
---@return table
function M.request(method, url, headers, data)
  data = data or {}
  data.per_page = 100

  local page = 1
  local all = {}
  local count

  repeat
    data.page = page

    local query = {}
    for k, v in pairs(data) do
      if v ~= nil then
        table.insert(query, k .. "=" .. v)
      end
    end

    local response = curl.request {
      method = method,
      url = url .. "?" .. table.concat(query, "&"),
      headers = headers,
    }

    if not response or response.status ~= 200 then
      break
    end

    local body = vim.json.decode(response.body)

    if not body then
      break
    end

    count = vim.tbl_count(body)
    page = page + 1

    vim.list_extend(all, body)
  until count < data.per_page

  return all
end

return M
