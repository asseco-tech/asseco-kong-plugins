-- Copyright (C) Asseco Poland SA
local BasePlugin = require "kong.plugins.base_plugin"
require("kong.plugins.asseco-debug.serialize")

local DebugHandler = BasePlugin:extend()
DebugHandler.PRIORITY = 5000
DebugHandler.VERSION = "1.0.0"

function DebugHandler:new()
  DebugHandler.super.new(self, "asseco-debug")
end

function DebugHandler:access(conf)
  DebugHandler.super.access(self)

  local ngx_log_level = ngx.INFO
  if conf.writing_log_level == "off" then
    return
  elseif conf.writing_log_level == "debug" then
    ngx_log_level = ngx.DEBUG
  elseif conf.writing_log_level == "info" then
    ngx_log_level = ngx.INFO
  elseif conf.writing_log_level == "notice" then
    ngx_log_level = ngx.NOTICE
  else
    return
  end

  --local started_at = ngx.req.start_time()
  --local started_str = os.date('%d/%b/%Y:%H:%M:%S',started_at)

  local headers = ngx.req.get_headers()
  --local method = ngx.req.get_method()
  --local request_uri = ngx.var.request_uri or ""
  -- method, " ", request_uri,

  local xfor_str = serializeTable( headers["x-forwarded-for"] or "", "x-forwarded-for", true )

  ngx.log(ngx_log_level,
          xfor_str,
          ", remote_addr: ", tostring(ngx.var.remote_addr),
          ", x-real-ip: ", tostring(headers["x-real-ip"]),
          ", user-agent: ", headers["user-agent"] or "",
          ", x-forwarded-proto: ", headers["x-forwarded-proto"] or "",
          ", x-forwarded-port: ", headers["x-forwarded-port"] or "" )
end

return DebugHandler
