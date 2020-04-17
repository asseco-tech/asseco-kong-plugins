-- Copyright (C) Asseco Poland SA
local BasePlugin = require "kong.plugins.base_plugin"
require("kong.plugins.asseco-jwt-cloner.parseurl")

local ClonerHandler = BasePlugin:extend()
ClonerHandler.PRIORITY = 1100  -- higher priority than jwt Kong Plugin
ClonerHandler.VERSION = "1.0.0"

function ClonerHandler:new()
  ClonerHandler.super.new(self, "asseco-jwt-cloner")
end

function ClonerHandler:access(conf)
  ClonerHandler.super.access(self)

  local cloning_field = conf.cloning_field or ''
  ngx.log(ngx.DEBUG, "plugin Params",
                     ", cloning_field: " .. cloning_field,
                     ", header_overwrite: " .. tostring(conf.header_overwrite))
  if #cloning_field < 1 then return end

  local headers = ngx.req.get_headers()
  local method = ngx.req.get_method() or ''
  local contentType = headers["content-type"] or ''
  local ifWriteHeader = headers["authorization"] == nil or conf.header_overwrite
  ngx.log(ngx.DEBUG, "ifWriteHeader: " .. tostring(ifWriteHeader),
                     ", method: " .. method,
                     ", contentType: " .. contentType)

  if not ifWriteHeader then return end
  if not (method == "POST" or method == "PUT" or method == "PATCH") then return end
  if not string.find(contentType, "x-www-form-urlencoded", 1, true) then return end

  ngx.req.read_body()
  local body = ngx.req.get_body_data()
  --ngx.log(ngx.DEBUG, "body: " .. tostring(body))
  if not body then
    ngx.log(ngx.DEBUG, "body is empty")
    return
  end

  local body_length = #body
  ngx.log(ngx.DEBUG, "body_length: " .. body_length)
  if (body_length <= 50) then return end

  local jwtKey = parseurl(body, cloning_field)
  --ngx.log(ngx.DEBUG, "jwtKey: " .. tostring(jwtKey))
  if not jwtKey then return end
  if #jwtKey <= 1 then return end

  ngx.log(ngx.DEBUG, "SET Authorization header")
  ngx.req.set_header("authorization", "Bearer " .. jwtKey)
end

return ClonerHandler
