local Path = require("plenary.path")
local utils = require("cmp_pandoc.utils")
local Scan = require("plenary.scandir")
local Filetype = require("plenary.filetype")

local M = {}

M.yaml_front_matter = function(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)

  local yaml_start = nil
  local yaml_end = nil

  local function is_valid(str)
    local match = string.match(str, "^%-%-%-") or string.match(str, "^%.%.%.")

    if match then
      if string.len(match) == 3 then
        return true
      end

      if string.sub(match, string.len(match) + 1, string.len(str)):match("^%s+") then
        return true
      end

      return false
    end

    return false
  end

  local i = 1

  while i <= #lines do
    if string.match(lines[i], "^%-%-%-") and is_valid(lines[i]) and not yaml_start then
      yaml_start = i
      i = i + 1
    end
    if is_valid(lines[i]) then
      yaml_end = i
      break
    end
    i = i + 1
  end

  local previous_line_is_empty = (function()
    if yaml_start == nil then
      return
    end
    if yaml_start > 1 then
      return string.len(lines[yaml_start - 1]) == 0
    end
    return true
  end)()

  local is_valid_yaml = yaml_start ~= nil and yaml_end ~= nil and (yaml_start ~= yaml_end) and previous_line_is_empty

  return {
    is_valid = is_valid_yaml,
    start = yaml_start,
    ["end"] = yaml_end,
    raw_content = is_valid_yaml and vim.list_slice(lines, yaml_start + 1, yaml_end - 1) or nil,
  }
end

M.get_bibliography_paths = function(bufnr)
  local front_matter = M.yaml_front_matter(bufnr)

  if not front_matter.is_valid then
    return
  end

  local bibliography_line = nil

  for index, value in ipairs(front_matter.raw_content) do
    if string.match(value, "^bibliography:") then
      bibliography_line = index
      break
    end
  end

  if not bibliography_line then
    return
  end

  local bibliography_field = vim.trim(string.match(front_matter.raw_content[bibliography_line], ":(.*)"))

  if string.len(bibliography_field) > 0 then
    return { bibliography_field }
  end

  local bibliography_inputs = {}

  local i = 1

  while i <= #front_matter.raw_content do
    if string.match(front_matter.raw_content[i], "^%-%s[%w|%d|%D]+") then
      table.insert(bibliography_inputs, front_matter.raw_content[i])
    end
    i = i + 1
  end

  if #bibliography_inputs == 0 then
    return
  end

  return vim.tbl_map(function(bibliography)
    return vim.trim(string.match(bibliography, "-%s(.*)"))
  end, bibliography_inputs)
end

local read_file = function(url)
  if not url:sub(1, 1) == "/" then
    url = Path.new(vim.api.nvim_buf_get_name(0)):parent():joinpath(url):absolute()
  end

  if Path:new(url):exists() then
    local file = io.open(url, "rb")
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

  for citation in data:gmatch("@.-\n}") do
    table.insert(o, citation)
  end

  return vim.tbl_map(function(citation)
    local documentation = vim.tbl_map(function(field)
      return utils.format(citation, field)
    end, opts.fields)

    return utils.format_entry({
      label = citation:match("@%w+{(.-),"),
      doc = opts.documentation,
      kind = "Field",
      value = table.concat(documentation, "\n"),
    })
  end, o)
end

M.bibliography = function(bufnr, opts)
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

local crossreferences = function(line, opts)
  for _, value in pairs({
    utils.crossref_patterns.div_ticks,
    utils.crossref_patterns.div_fence,
  }) do
    if string.match(line, value) then
      local caption = string.match(line, [[._-caption=['"]([^\r]+)["'].-}]]) or ""
      return utils.format_entry({
        label = string.match(line, value),
        value = "*" .. vim.trim(caption) .. "*",
      })
    end
  end

  if string.match(line, utils.crossref_patterns.div_html) then
    return utils.format_entry({
      label = string.match(line, utils.crossref_patterns.div_html),
      value = "*" .. vim.trim(string.match(line, [[._-caption=['"]([^\r]+)["'].->]]) or "") .. "*",
    })
  end

  if string.match(line, utils.crossref_patterns.equation) and string.match(line, "^%$%$(.*)%$%$") then
    local equation = string.match(line, "^%$%$(.*)%$%$")
    return utils.format_entry({
      label = string.match(line, utils.crossref_patterns.equation),
      doc = opts.documentation,
      value = opts.enable_nabla and utils.nabla(equation) or equation,
    })
  end

  if string.match(line, utils.crossref_patterns.section) and string.match(line, "^#+%s+(.*){") then
    return utils.format_entry({
      label = string.match(line, utils.crossref_patterns.section),
      value = "*" .. vim.trim(string.match(line, "#%s+(.*){") or "") .. "*",
    })
  end

  if string.match(line, utils.crossref_patterns.table) then
    return utils.format_entry({
      label = string.match(line, utils.crossref_patterns.base),
      value = "*" .. vim.trim(string.match(line, "^:%s+(.*)%s+{") or "") .. "*",
    })
  end

  if string.match(line, utils.crossref_patterns.lst) then
    return utils.format_entry({
      label = string.match(line, utils.crossref_patterns.lst),
      value = "*" .. vim.trim(string.match(line, "^:%s+(.*)%s+{") or "") .. "*",
    })
  end

  if string.match(line, utils.crossref_patterns.figure) then
    return utils.format_entry({
      label = string.match(line, utils.crossref_patterns.figure),
      value = "*" .. vim.trim(string.match(line, "^%!%[.*%]%((.*)%)") or "") .. "*",
    })
  end
end

local valid_references = function(path)
  local data = read_file(path)

  if not data then
    return
  end
  data = data:gsub("\\n", "\n"):gsub("\\r", "\r")
  local datatable = {}
  for s in data:gmatch("[^\r\n]+") do
    datatable[#datatable + 1] = s
  end

  return vim.tbl_filter(function(line)
    return (line:match(utils.crossref_patterns.base) or line:match(utils.crossref_patterns.base_div))
      and not line:match("^%<!%-%-(.*)%-%-%>$")
  end, datatable)
end

M.references = function(opts, filetypes)
  local references_path =
    Scan.scan_dir(Path:new(vim.api.nvim_buf_get_name(0)):parents()[2], { hidden = true, depth = 2 })
  local all_valid_lines = {}

  local valid_lines = {}
  local lookup = false
  for _, path in ipairs(references_path) do
    lookup = false
    for _, filetype in ipairs(filetypes) do
      if filetype == Filetype.detect(path) then
        lookup = true
        break
      end
    end

    if lookup then
      valid_lines = valid_references(path)
      if valid_lines then
        vim.list_extend(all_valid_lines, valid_lines)
      end
    end
  end

  if vim.tbl_isempty(all_valid_lines) then
    return
  end

  return vim.tbl_map(function(line)
    return crossreferences(line, opts)
  end, all_valid_lines)
end

M.init = function(self, callback, bufnr)
  local opts = self and self.opts or require("cmp_pandoc.config")

  local bib_items = M.bibliography(bufnr, opts.bibliography)
  local reference_items = M.references(opts.crossref, opts.filetypes)

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
