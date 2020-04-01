local BasePlugin = require("kong.plugins.base_plugin")
local JwtPluginHandler = BasePlugin:extend()
local _cjson_decode_ = require("cjson").decode
local _cjson_encode_ = require("cjson").encode

local base64 = require("kong.plugins.asseco-jwt-transformer.base64")
local md5 = require("kong.plugins.asseco-jwt-transformer.md5")

local _get_env_ = function()
  return {
    ngx = {
      ctx = ngx.ctx,
      var = ngx.var,
      req = {
        get_headers =  ngx.req.get_headers,
        set_header = ngx.req.set_header,
        get_body_data = ngx.req.get_body_data,
        set_body_data = ngx.req.set_body_data,
      },
      resp = {
        get_headers = ngx.resp.get_headers,
      }
    }
  }
end

-- checks if table contains specified element
function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end


function JwtPluginHandler:new()
  JwtPluginHandler.super.new(self, 'asseco-jwt-transformer')
end


function JwtPluginHandler:access(config)
  JwtPluginHandler.super.access(self)

  ngx.req.read_body()

  local s, req_json_body = pcall(function() return _cjson_decode_(ngx.req.get_body_data()) end)
  if not s then
    req_json_body = nil
  end

  -- save values into context for later usage
  ngx.ctx._validation_error_in_access_phase = false
  ngx.ctx.req_headers = ngx.req.get_headers()
  ngx.ctx.req_json_body = req_json_body

  local req_body_out = _cjson_encode_(ngx.ctx.req_json_body)

  local auth_header = tostring(ngx.ctx.req_headers["Authorization"])

  -- does 'Authorization' header exist / is it empty?
  if auth_header == 'nil' then
    ngx.ctx._validation_error_in_access_phase = true
    return kong.response.exit(401, [[{"message":"No authorization data"}]], {["Content-Type"] = "application/json"})
  end

  -- token decomposition
  local parts = {}
  for part in string.gmatch(auth_header, "%w+") do
    table.insert(parts, part)
  end

  local payload = base64.decode(parts[3]);

  -- output json should have the following structure:
  -- {
  --   "jwt": {
  --     "field1": "token_field1_value | token_field1_hashed_value",
  --     "field2": "token_field2_value | token_field2_hashed_value",
  --     ...,
  --   },
  --   [request body]
  -- }
  local outJson = {}
  if ngx.ctx.req_json_body ~= nil then
    outJson = ngx.ctx.req_json_body
  end
  if config.cloning_place == "body" then
    outJson["jwt"] = {}
  end

  -- fields for clonning their values
  if config.cloning_fields ~= nil and #config.cloning_fields > 0 then
    for key, value in ipairs(config.cloning_fields) do
      if payload[value] ~= nil then
        if config.cloning_place == "body" then
          outJson.jwt[value] = payload[value]
        else
          ngx.req.set_header("X-JWT-" .. value, payload[value])
        end
      end
    end
  end

  -- fields for clonning their hashed values
  if config.hashed_cloning_fields ~= nil and #config.hashed_cloning_fields > 0 then
    for key, value in ipairs(config.hashed_cloning_fields) do
      if payload[value] ~= nil then
        if config.cloning_place == "body" then
          outJson.jwt[value] = md5.sumhexa(payload[value])
        else
          ngx.req.set_header("X-JWT-" .. value, md5.sumhexa(payload[value]))
        end
      end
    end
  end

  req_body_out = _cjson_encode_(outJson)

  kong.log.inspect(req_body_out)

  ngx.req.set_body_data(req_body_out)
  ngx.req.set_header(CONTENT_LENGTH, #req_body_out)

  ngx.ctx._resp_buffer = ''
end


function JwtPluginHandler:header_filter(config)
  JwtPluginHandler.super.header_filter(self)

  if ngx.ctx._validation_error_in_access_phase then
    ngx.status = 401
    return
  end
  ngx.header["content-length"] = nil -- this needs to be for the content-length to be recalculated
end


function JwtPluginHandler:body_filter(config)
  JwtPluginHandler.super.body_filter(self)

  if ngx.ctx._validation_error_in_access_phase or ngx.ctx._no_session_error_in_access_phase then
    return
  end

  -- it should allow to pass the output of the previous plugin (e.g. jwt)
  if ngx.status ~= 200 and ngx.status ~= 500 then return end

  local chunk, eof = ngx.arg[1], ngx.arg[2]

  if not eof then
    if ngx.ctx._resp_buffer and chunk then
      ngx.ctx._resp_buffer = ngx.ctx._resp_buffer .. chunk
    end
    ngx.arg[1] = nil

  else
    -- body is fully read
    local raw_body = ngx.ctx._resp_buffer
    if raw_body == nil then
      return ngx.ERROR
    end

    ngx.ctx.resp_headers = ngx.resp.get_headers()
    local hdrContentType = ngx.ctx.resp_headers["Content-Type"]
    local hdrContentEncoding = ngx.ctx.resp_headers["Content-Encoding"] -- do nothing for compressed response (gzip)
    if hdrContentEncoding == nil and hdrContentType ~= nil and string.find(hdrContentType, 'application/json') ~= nil then
      kong.log.inspect("#### BODY: " .. raw_body)
      ngx.ctx.resp_json_body = _cjson_decode_(raw_body)
      if ngx.ctx.resp_json_body.out ~= nil then
        -- flatten the response
        ngx.arg[1] = _cjson_encode_(ngx.ctx.resp_json_body.out)
      else
        ngx.arg[1] = _cjson_encode_(ngx.ctx.resp_json_body)
      end
    else
      ngx.arg[1] = raw_body
    end
  end
end


JwtPluginHandler.PRIORITY = 801

return JwtPluginHandler
