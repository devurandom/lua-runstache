package = "runstache"
version = "0.0.1-0"
source = {
  url = "https://github.com/urzds/runstache/archive/v0.0.1-0.tar.gz",
  dir = "runstache-0.0.1-0"
}
description = {
  summary = "Standalone {{mustache}} rendering with Lua",
  detailed = [[
    A standalone template instantiation script for mustache templates in Lua.
    Find out more about Mustache at http://mustache.github.com.
  ]],
  homepage = "https://github.com/urzds/runstache/",
  license = "MIT <http://opensource.org/licenses/MIT>"
}
dependencies = {
  "lustache >= 1.3"
}
build = {
  type = "none",
  install = {
    bin = {
      runstache = "runstache.lua",
    }
  },
}
