local Path = require("plenary.path")
local utils = require("cmp_pandoc.utils")

local M = {}

local get_line = function(bufnr, i, j)
  return vim.api.nvim_buf_get_lines(bufnr or 0, i == 0 and i or i - 1, j == -1 and j or j + 1, true)
end

M.get_bibliography_paths = function(bufnr)

  local lines = get_line(bufnr, 0, -1)

  local function yaml_block_position()
    local yaml_metadata_start
    local yaml_metadata_end

    local i = 1
    while i <= #lines do

      if lines[i]:match('^%-%-%-$') and not yaml_metadata_start then
        yaml_metadata_start = i
        i = i + 1
      end

      if (lines[i]:match('^%-%-%-$') or lines[i]:match('^%.%.%.$')) then
        yaml_metadata_end = i
        break
      end

      i = i + 1
    end

    local is_valid = (yaml_metadata_start ~= nil and yaml_metadata_end ~= nil) and (yaml_metadata_start ~= yaml_metadata_end)
    return is_valid, yaml_metadata_start, yaml_metadata_end
  end

  local header_exists, header_start, header_end = yaml_block_position()

  if not header_exists then
    return
  end


  local yaml_header = vim.list_slice(lines, header_start + 1, header_end - 1)

  local bibliography_line_number

  for index, value in ipairs(yaml_header) do
    if value:match('bibliography:') then
      bibliography_line_number = index
    end
  end

  if not bibliography_line_number then
    return
  end

  -- If is a single bib file
  local bib_input = vim.trim(yaml_header[bibliography_line_number]:match(':(.*)'))

  if bib_input and bib_input:len() > 0 then
    return { bib_input }
  end

  local bib_inputs = {}

  local s = vim.list_slice(yaml_header, bibliography_line_number, #yaml_header)
  local i = 1

  while i <= #s do
    if s[i]:match('^%-%s[%w|%d|%D]+') then
      table.insert(bib_inputs, s[i])
    end
    i = i + 1
  end

  return vim.tbl_map(function (bib)
    return vim.trim(bib:match('-%s(.*)'))
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

  return vim.tbl_map(function (citation)

    local documentation = vim.tbl_map(function (field)
      return utils.format(citation, field)
    end, opts.fields)

    return utils.format_entry{
      label = citation:match('@%w+{(.-),'),
      doc = opts.documentation,
      kind = 'Field',
      value = table.concat(documentation, '\n')
    }
  end, o)

end

M.parse_bib = function(bufnr, opts)
  local bib_paths = M.get_bibliography_paths(bufnr)

  if not bib_paths then
    return
  end

  local all_bib_entrys = {}

  for _, path in ipairs(bib_paths) do
    local citation = citations(path, opts)
    if citation then
      vim.list_extend(all_bib_entrys, citation)
    end
  end

  return all_bib_entrys
end

local references = function(line, opts)
  if line:match(utils.crossref_patterns.equation) and line:match("^%$%$(.*)%$%$") then
    local equation = line:match("^%$%$(.*)%$%$")

    return utils.format_entry({
      label = line:match(utils.crossref_patterns.equation),
      doc = opts.documentation,
      value = opts.enable_nabla and utils.nabla(equation) or equation,
    })
  end

  if line:match(utils.crossref_patterns.section) and line:match('^#%s+(.*){') then
    return utils.format_entry({
      label = line:match(utils.crossref_patterns.section),
      value = "*" .. vim.trim(line:match("#%s+(.*){")) .. "*",
    })
  end

  if line:match(utils.crossref_patterns.table) then
    return utils.format_entry({
      label = line:match(utils.crossref_patterns.base),
    })
  end

  if line:match(utils.crossref_patterns.lst) then
    return utils.format_entry({
      label = line:match(utils.crossref_patterns.lst),
    })
  end
end

M.parse_ref = function(bufnr, opts)

  local valid_lines = vim.tbl_filter(function (line)
    return line:match(utils.crossref_patterns.base) and not line:match('^%<!%-%-(.*)%-%-%>$')
  end, get_line(bufnr, 0, -1))

  if vim.tbl_isempty(valid_lines) then
    return
  end

  return vim.tbl_map(function (line)
    return references(line, opts)
  end, valid_lines)

end

M.parse = function(self, callback, bufnr)
  local opts = self and self.opts or require("cmp_pandoc.config")

  local bib_items = M.parse_bib(bufnr, opts.bibliography)
  local reference_items = M.parse_ref(bufnr, opts.crossref)

  local all_entrys = {}

  if reference_items then
    vim.list_extend(all_entrys, reference_items)
  end

  if bib_items then
    vim.list_extend(all_entrys, bib_items)
  end

  if not all_entrys then
    return callback()
  end
  return callback(all_entrys)
end

return M
