-- Copyright (C) Asseco Poland SA
--[[ -------------------------------------------------
Plugin Description:
    Copying JWT Key from request body to Authorization header.
    Supported Content-Type: x-www-form-urlencoded.

Plugin Params:
 - config.cloning_field - field name in body with JWT Key
 - config.header_overwrite - overwrite existing Authorization header
--]]

local typedefs = require "kong.db.schema.typedefs"

return {
  name = "asseco-jwt-cloner",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
            { cloning_field = { type = "string" }},
            { header_overwrite = { type = "boolean", default = true }},
        }
      }
    }
  }
}
