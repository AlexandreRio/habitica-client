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

  if (body ~= nil) then
    local jsonbody = json.encode(body)

    headers["content-length"] = #jsonbody
    https.request{
      url = "https://habitica.com/api/v3/" .. path,
      method = method,
      source = ltn12.source.string(jsonbody),
      sink = ltn12.sink.file(io.stdout),
      headers = headers
    }
  else
    https.request{
      url = "https://habitica.com/api/v3/" .. path,
      method = method,
      sink = ltn12.sink.file(io.stdout),
      headers = headers
    }
  end
end

function habitica.create_todo(text)
  local req = {}
  req["type"] = "todo"
  req["text"] = text

  local url = "tasks/user"
  habitica.request(url, "POST", req)
end

function habitica.list_tasks()
  habitica.request("tasks/user", "GET", nil)
end

function habitica.getTags()
  habitica.request("tags", "GET", nil)
end

return habitica
