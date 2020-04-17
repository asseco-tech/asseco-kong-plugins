-- Copyright (C) Asseco Poland SA
return {
  name = "asseco-myheader",
  fields = {
    { config = {
        type = "record",
        fields = {
            {header_flag = { type = "boolean", default = true },},
            {header_value = { type = "string", default = "plugin asseco myheader" }},
        }
    }}
  }
}
