local nabla_avilable, _ = pcall(require, "nabla")
local cmp = require("cmp")
local M = {}

local bib_patterns = {
  id = "@%w+{(.-),",
  type = "@(%w+)",
  title = "title%s*=%s*[{]*(.-)[}],",
  author = 'author%s*=%s*["{]*(.-)["}],?',
  year = 'year%s*=%s*["{]?(%d+)["}]?,?',
}

local template = {
  type = "# %s",
  title = "*%s*",
  author = "- %s",
  year = "%s",
}

local crossref_patterns = {
  base = "{#(%a+:[%w_-]+)",
  base_div = "<%s*div.->",
  equation = "{#(eq:[%w_-]+)",
  section = "{#(sec:[%w_-]+)",
  figure = "{#(fig:[%w_-]+)",
  table = "{#(tbl:[%w_-]+)",
  lst = "{#(lst:[%w_-]+)",
  div_fence = ":::%s*%{#([%w_-]+:[%w_-]+)",
  div_ticks = "```%s*%{#([%w_-]+:[%w_-]+)",
  div_html = [[<%s*div.-id=["']([%w_-]+:[%w_-]+)]]
}

M.crossref_patterns = crossref_patterns
M.bib_patterns = bib_patterns

M.format = function(str, field)
  local pattern_field = bib_patterns[field]
  local match_field = string.match(str, pattern_field)
  if not match_field then
    return ""
  end
  local format = match_field:gsub("\n", " "):gsub("%s+", " ")

  if field == "type" then
    format = format:gsub("^%l", string.upper)
  end

  local format_with_template = string.format(template[field], format)
  return format_with_template
end

M.format_entry = function(opts)
  if not opts.label then return nil end
  local label_prefix = opts.prefix or "@"
  local kind = cmp.lsp.CompletionItemKind[opts.kind] or cmp.lsp.CompletionItemKind.Reference
  local doc = opts.doc or true
  local doc_kind = opts.doc_kind or cmp.lsp.MarkupKind.Markdown
  return {
    label = label_prefix .. opts.label,
    kind = kind,
    documentation = doc and {
      kind = doc_kind,
      value = opts.value,
    } or nil,
  }
end

M.nabla = function(str)
  if not nabla_avilable then
    return "nabla not found"
  end

  local parser = require("nabla.latex")
  local ascii = require("nabla.ascii")

  local parsed, exp = pcall(parser.parse_all, str)
  if not parsed then
    return "nabla: error parsing " .. str
  end

  local parsed_to_ascii, result = pcall(ascii.to_ascii, exp)
  if not parsed_to_ascii then
    return "nabla: error parsing to ascii " .. str
  end

  local drawing = {}
  for row in vim.gsplit(tostring(result), "\n") do
    table.insert(drawing, row)
  end
  return table.concat(drawing, "\n")
end

return M
