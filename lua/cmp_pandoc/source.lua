local config = require("cmp_pandoc.config")
local parse = require("cmp_pandoc.parse")

local source = {
  opts = {},
}

source.new = function(overrides)
  local self = setmetatable({}, { __index = source })

  self.opts = vim.tbl_extend("force", config, overrides or {})
  return self
end

source.complete = function(self, params, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  parse.init(self, callback, bufnr)
end

source.is_available = function(self)
  return vim.tbl_contains(self.opts.filetypes, vim.bo.filetype)
end

source.get_keyword_pattern = function(self)
  return "[@][^[:blank:]]*"
end

source.get_trigger_characters = function(self)
  return { "@" }
end

source.get_debug_name = function(self)
  return "pandoc"
end

return source
