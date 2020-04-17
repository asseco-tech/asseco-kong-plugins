package = "asseco-jwt-transformer"
version = "0.1.0-0"
source = {
   url = "https://github.com/asseco-tech/asseco-kong-plugins.git"
}
description = {
  summary = "A Kong plugin that clones data from authorization header to request body/headers",
  license = "Apache License 2.0",
  maintainer = "robert.wieckowicz@asseco.pl"
}
dependencies = {
  "lua >= 5.1",
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.asseco-jwt-transformer.handler"] = "./plugin/handler.lua",
    ["kong.plugins.asseco-jwt-transformer.schema"] = "./plugin/schema.lua",
    ["kong.plugins.asseco-jwt-transformer.md5"] = "./plugin/md5.lua",
    ["kong.plugins.asseco-jwt-transformer.base64"] = "./plugin/base64.lua"
  }
}
