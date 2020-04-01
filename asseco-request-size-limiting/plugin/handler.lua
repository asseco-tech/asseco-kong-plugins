-- Copyright (C) Kong Inc.
-- Copyright (C) Asseco Poland SA

local BasePlugin = require "kong.plugins.base_plugin"
local strip = require("pl.stringx").strip
local tonumber = tonumber

local KB = 1024     -- 2 ^ 10 bytes
local RequestSizeLimitingHandler = BasePlugin:extend()

RequestSizeLimitingHandler.PRIORITY = 950
RequestSizeLimitingHandler.VERSION = "1.0.0"

local payload_size_kind = {
  "by-header",
  "by-raw-content",
}
RequestSizeLimitingHandler.payload_size_kind = payload_size_kind

function RequestSizeLimitingHandler:new()
  RequestSizeLimitingHandler.super.new(self, "asseco-request-size-limiting")
end



local function check_body_size(length, allowed_size, headers)
  local allowed_bytes_size = allowed_size * KB

  if length > allowed_bytes_size then
    if headers.expect and strip(headers.expect:lower()) == "100-continue" then
      return kong.response.exit(417, { message = "Request Body size limit exceeded" })
    else
      return kong.response.exit(413, { message = "Request Body size limit exceeded" })
    end
  end
end


local function check_headers_size(length, allowed_size, headers)
  local allowed_bytes_size = allowed_size * KB

  if length > allowed_bytes_size then
    if headers.expect and strip(headers.expect:lower()) == "100-continue" then
      return kong.response.exit(417, { message = "Request Headers size limit exceeded" })
    else
      return kong.response.exit(431, { message = "Request Headers size limit exceeded" })
    end
  end
end


function RequestSizeLimitingHandler:access(conf)
  RequestSizeLimitingHandler.super.access(self)
  local headers = ngx.req.get_headers()
  local cl = headers["content-length"]
  local ct = headers["content-type"]

  ngx.log(ngx.DEBUG, "config.allowed_payload_size_text: ", conf.allowed_payload_size_text, " KB")
  ngx.log(ngx.DEBUG, "config.allowed_payload_size_binary: ", conf.allowed_payload_size_binary, " KB")
  ngx.log(ngx.DEBUG, "config.allowed_headers_size: ", conf.allowed_headers_size, " KB")
  ngx.log(ngx.DEBUG, "config.payload_size_check: ", conf.payload_size_check)
  ngx.log(ngx.DEBUG, "content-length: ", cl, " B")
  ngx.log(ngx.DEBUG, "content-type: ", ct)

  local raw_header = ngx.req.raw_header()
  local headers_length = #raw_header

  ngx.log(ngx.DEBUG, "raw header size: ", headers_length)
  check_headers_size(headers_length, conf.allowed_headers_size, headers)

  if not ct or ct == '' then
    ct = conf.default_content_type
  end

  -- by-header
  if     conf.payload_size_check == "by-header"
     and cl and tonumber(cl) then
    if    string.find(ct, 'json', 1, true)
       or string.find(ct, 'javascript', 1, true)
       or string.find(ct, 'text', 1, true)  then
      -- JSON, JavaScript, text
      check_body_size(tonumber(cl), conf.allowed_payload_size_text, headers)
    else
      -- binary
      check_body_size(tonumber(cl), conf.allowed_payload_size_binary, headers)
    end

  -- raw-body
  else
    ngx.req.read_body()
    local data = ngx.req.get_body_data()
    local data_length = 0
    if data then
      data_length = #data
      ngx.log(ngx.DEBUG, "data_length")
    else
        local body_file = ngx.req.get_body_file()
        if body_file then
            ngx.log(ngx.NOTICE,"body is in file " )
            local body_file_handle, err = io.open(body_file, "r")
            if body_file_handle then
                body_file_handle:seek("set")
                request_body = body_file_handle:read("*a")
                body_file_handle:close()
            end
         end
    ngx.log(ngx.DEBUG, "raw body: ", data)
    ngx.log(ngx.DEBUG, "content body size: ", data_length)

    if    string.find(ct, 'json', 1, true)
       or string.find(ct, 'javascript', 1, true)
       or string.find(ct, 'text', 1, true)  then
      -- JSON, JavaScript, text
      check_body_size(data_length, conf.allowed_payload_size_text, headers)
    else
      -- binary
      check_body_size(data_length, conf.allowed_payload_size_binary, headers)
    end
  end

end

return RequestSizeLimitingHandler
