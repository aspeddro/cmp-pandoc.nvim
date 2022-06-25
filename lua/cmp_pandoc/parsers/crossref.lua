local utils = require("cmp_pandoc.utils")
local literals = require("cmp_pandoc.literals")

local M = {}

---Get crossreferences
---@param line string
---@param opts table
---@return table|nil
M.handle = function(line, opts)
  if string.match(line, literals.crossref_patterns.equation) and string.match(line, "^%$%$(.*)%$%$") then
    local equation = string.match(line, "^%$%$(.*)%$%$")

    return utils.format_entry({
      label = string.match(line, literals.crossref_patterns.equation),
      doc = opts.documentation,
      value = opts.enable_nabla and utils.nabla(equation) or equation,
    })
  end

  if string.match(line, literals.crossref_patterns.section) and string.match(line, "^#%s+(.*){") then
    return utils.format_entry({
      label = string.match(line, literals.crossref_patterns.section),
      value = "*" .. vim.trim(string.match(line, "#%s+(.*){")) .. "*",
    })
  end

  if string.match(line, literals.crossref_patterns.table) then
    return utils.format_entry({
      label = string.match(line, literals.crossref_patterns.base),
      value = "*" .. vim.trim(string.match(line, "^:%s+(.*)%s+{")) .. "*",
    })
  end

  if string.match(line, literals.crossref_patterns.lst) then
    return utils.format_entry({
      label = string.match(line, literals.crossref_patterns.lst),
      value = "*" .. vim.trim(string.match(line, "^:%s+(.*)%s+{")) .. "*",
    })
  end

  if string.match(line, literals.crossref_patterns.figure) then
    return utils.format_entry({
      label = string.match(line, literals.crossref_patterns.figure),
      value = "*" .. vim.trim(string.match(line, "^%!%[.*%]%((.*)%)")) .. "*",
    })
  end
end

return M
