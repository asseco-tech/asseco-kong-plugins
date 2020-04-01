local typedefs = require "kong.db.schema.typedefs"
local handler = require "kong.plugins.asseco-request-size-limiting.handler"
local payload_size_kind = handler.payload_size_kind

return {
  name = "asseco-request-size-limiting",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { allowed_payload_size_text = { default = 100, type = "number" }},
          { allowed_payload_size_binary = { default = 1024, type = "number" }},
          { allowed_headers_size = { default = 10, type = "number" }},
          { payload_size_check = { type = "string", default = payload_size_kind[1], one_of = payload_size_kind }},
          { default_content_type = { default = "application/json", type = "string" }},
        }
      }
    }
  }
}
