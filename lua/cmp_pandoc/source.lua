local config = require("cmp_pandoc.config")
local parse = require("cmp_pandoc.parse")

local Source = {}

Source.new = function(overrides)
  local self = setmetatable({}, { __index = Source })

  self.opts = vim.tbl_extend("force", config, overrides or {})
  return self
end

Source.complete = function(self, params, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  parse.init(self, callback, bufnr)
end

Source.is_available = function(self)
  return vim.tbl_contains(self.opts.filetype, vim.bo.filetype)
end

Source.get_keyword_pattern = function(self)
  -- return "[@][^[:blank:]]*"
  return self.opts.keyword_pattern
end

Source.get_trigger_characters = function(self)
  return { "@" }
end

Source.get_debug_name = function(self)
  return "pandoc"
end

return Source
