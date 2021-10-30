local Source = require("cmp_pandoc.source")

local M = {}

M.setup = function(overrides)
  require("cmp").register_source("cmp_pandoc", Source.new(overrides))
end

return M
