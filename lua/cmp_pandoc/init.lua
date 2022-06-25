local source = require("cmp_pandoc.source")

local M = {}

---Setup cmp-pandoc
---@param opts table
---@usage `require('cmp_pandoc').setup()`
M.setup = function(opts)
  local cmp_pandoc = source.new(opts)
  local notified = false
  cmp_pandoc.complete = function (cmp_pandoc, params, callback)
    if not notified then
      vim.notify("[cmp-pandoc]: source name 'cmp_pandoc' is depreacted. Change this to 'pandoc'", vim.log.levels.WARN)
      notified = true
    end
  end
  require("cmp").register_source("cmp_pandoc", cmp_pandoc)
  require("cmp").register_source("pandoc", source.new(opts))
end

return M
