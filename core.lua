local https = require "ssl.https"
local ltn12 = require "ltn12"
local json  = require "json"

local config = require "config"

local habitica = {}

function habitica.getHeaders() 
  local headers = {}
  headers["Content-Type"] = "application/json"
  headers["x-api-user"] = config.user
  headers["x-api-key"] = config.key
  return headers
end

function habitica.request(path, method, body)
  local headers = habitica:getHeaders()
  local response = {}

  if (body ~= nil) then
    local jsonbody = json.encode(body)

    headers["content-length"] = #jsonbody
    https.request{
      url = "https://habitica.com/api/v3/" .. path,
      method = method,
      source = ltn12.source.string(jsonbody),
      sink = ltn12.sink.table(response),
      headers = headers
    }
  else
    https.request{
      url = "https://habitica.com/api/v3/" .. path,
      method = method,
      sink = ltn12.sink.table(response),
      headers = headers
    }
  end

  response = json.decode(table.concat(response))
  return response.success, response.message, response.data
end

function habitica.create_todo(text, tag)
  local req = {}
  req["type"] = "todo"
  req["text"] = text

  if (tag ~= nil) then
    req["tags"] = tag
  end

  local url = "tasks/user"

  return habitica.request(url, "POST", req)
end

function habitica.list_tasks()
  return habitica.request("tasks/user", "GET", nil)
end

function habitica.getTags()
  return habitica.request("tags", "GET", nil)
end

return habitica
