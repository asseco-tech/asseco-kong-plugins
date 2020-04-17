-- Copyright (C) Asseco Poland SA
-- inspiration: https://github.com/brndmg/kong-plugin-hello-world
local BasePlugin = require "kong.plugins.base_plugin"

local HelloWorldHandler = BasePlugin:extend()

HelloWorldHandler.PRIORITY = 2000
HelloWorldHandler.VERSION = "1.0.0"

function HelloWorldHandler:new()
  HelloWorldHandler.super.new(self, "asseco-myheader")
end

function HelloWorldHandler:access(conf)
  HelloWorldHandler.super.access(self)

  if conf.header_flag then
    ngx.log(ngx.NOTICE, "== x-hello-world ON ==")
    ngx.header["x-hello-world"] = conf.header_value
  else
    ngx.log(ngx.NOTICE, "== x-hello-world EMPTY ==")
    ngx.header["x-hello-world"] = ""
  end

end

return HelloWorldHandler
