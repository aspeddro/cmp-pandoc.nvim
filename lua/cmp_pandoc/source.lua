local config = require("cmp_pandoc.config")
local pandoc = require("cmp_pandoc.pandoc_parse")

local Source = {
  opts = {},
}

Source.new = function(overrides)
  local self = setmetatable({}, { __index = Source })

  self.opts = vim.tbl_extend("force", config, overrides or {})
  return self
end

function Source:complete(params, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  pandoc.parse(self, callback, bufnr)
end

function Source:is_available()
  return vim.tbl_contains(self.opts.filetypes, vim.bo.filetype)
end

function Source:get_keyword_pattern()
  return "[@][^[:blank:]]*"
end

function Source:get_trigger_characters()
  return { "@" }
end

function Source:get_debug_name()
  return 'pandoc'
end

return Source
