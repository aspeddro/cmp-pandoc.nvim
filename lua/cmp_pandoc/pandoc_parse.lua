local Path = require("plenary.path")
local utils = require("cmp_pandoc.utils")
local Tbl = require("cmp_pandoc.tbl")
local M = {}

local get_line = function(bufnr, i, j)
  return vim.api.nvim_buf_get_lines(bufnr or 0, i == 0 and i or i - 1, j == -1 and j or j + 1, true)
end

M.get_bibliography_paths = function(bufnr)
  local lines = get_line(bufnr, 0, -1)

  local bib_line

  for line_number, line in pairs(lines) do
    if line:match("bibliography:") then
      bib_line = line_number
      break
    end
  end

  if not bib_line then
    return
  end

  local line_content = get_line(bufnr, bib_line, bib_line)

  if #line_content == 0 then
    return
  end

  local bib_input = line_content[1]:match(":(.*)")

  -- Has a single input
  if bib_input and bib_input:len() > 0 then
    return { vim.trim(bib_input) }
  end

  local bib_inputs = {}
  local next_line = bib_line + 1
  -- Multiple entry yaml
  while next_line < vim.api.nvim_buf_line_count(bufnr) do
    local current_line = get_line(bufnr, next_line, next_line)[1]

    if current_line == "---" then
      break
    end

    if string.match(current_line, "^-") then
      table.insert(bib_inputs, current_line)
    end

    next_line = next_line + 1
  end
  return vim.tbl_map(function(bib_file)
    return vim.trim(string.match(bib_file, "-%s(.*)"))
  end, bib_inputs)
end

local read_file = function(path)
  local p = Path.new(vim.api.nvim_buf_get_name(0)):parent():joinpath(path):absolute()
  if Path:new(p):exists() then
    local file = io.open(p, "rb")
    local results = file:read("*all")
    file:close()
    return results
  end
end

local citations = function(path, opts)
  local data = read_file(path)

  if not data then
    return
  end

  local o = {}

  for citation in data:gmatch("@.-\n}\n") do
    table.insert(o, citation)
  end

  return Tbl:new(o):map(function(citation)
    return utils.format_entry({
      label = citation:match("@%w+{(.-),"),
      doc = opts.documentation,
      value = Tbl
        :new(opts.fields)
        :map(function(field)
          return utils.format(citation, field)
        end)
        :join(),
    })
  end)
end

M.parse_bib = function(bufnr, opts)
  local bib_paths = M.get_bibliography_paths(bufnr)

  if not bib_paths then
    return
  end

  local all_bib_entrys = Tbl:new()

  for _, path in ipairs(bib_paths) do
    all_bib_entrys:extend(citations(path, opts))
  end

  return all_bib_entrys
end

local references = function(line, opts)
  if line:match(utils.crossref_patterns.equation) then
    local equation = line:match("^%$%$(.*)%$%$")

    return utils.format_entry({
      label = line:match(utils.crossref_patterns.equation),
      doc = opts.documentation,
      value = opts.enable_nabla and utils.nabla(equation) or equation,
    })
  end

  if line:match(utils.crossref_patterns.section) then
    return utils.format_entry({
      label = line:match(utils.crossref_patterns.section),
      value = "*" .. vim.trim(line:match("#%s+(.*){")) .. "*",
    })
  end

  if line:match(utils.crossref_patterns.base) then
    return utils.format_entry({
      label = line:match(utils.crossref_patterns.base),
    })
  end

  error("Not found pattern for " .. line)
end

M.parse_ref = function(bufnr, opts)
  return Tbl
    :new(get_line(bufnr, 0, -1))
    :filter(function(line)
      return line:match(utils.crossref_patterns.base)
    end)
    :map(function(line)
      return references(line, opts)
    end)
end

M.parse = function(self, callback, bufnr)
  local opts = self.opts or require("cmp_pandoc.config")

  local bib_items = M.parse_bib(bufnr, opts.bibliography)
  local reference_items = M.parse_ref(bufnr, opts.crossref)

  local all_entrys = Tbl:new({})

  if reference_items then
    all_entrys:extend(reference_items)
  end

  if bib_items then
    all_entrys:extend(bib_items)
  end
  return callback(all_entrys)
end

return M
