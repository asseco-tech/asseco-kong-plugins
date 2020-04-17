-- Copyright (C) Asseco Poland SA
local typedefs = require "kong.db.schema.typedefs"

return {
  name = "asseco-debug",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
            { writing_log_level= { type = "string", default = "info", one_of = { "debug", "info", "notice", "off" }  }},
        }
      }
    }
  }
}
