local Path = require("plenary.path")
local nabla_avilable, _ = pcall(require, "nabla")
local cmp = require("cmp")
local literals = require("cmp_pandoc.literals")

local M = {}

M.format = function(str, field)
  local template = {
    type = "# %s",
    title = "*%s*",
    author = "- %s",
    year = "%s",
  }
  local pattern_field = literals.bib_patterns[field]
  local match_field = string.match(str, pattern_field)
  if not match_field then
    return ""
  end
  local format = match_field:gsub("\n", " "):gsub("%s+", " ")

  if field == "type" then
    format = format:gsub("^%l", string.upper)
  end

  if not template[field] then
    return ""
  end

  local format_with_template = string.format(template[field], format)
  return format_with_template
end

M.format_from_cli = function(str, field)
  local template = {
    title = "# %s",
    author = "*%s*",
    year = "- Year: %s",
    ["container-title"] = "- Journal: %s",
    page = "- Page: %s",
    volume = "- Vol: %s",
    edition = "- Edition: %s",
    DOI = "- DOI: %s",
    URL = "- URL: %s",
    issue = "- Issue: %s",
    publiser = "- Publiser: %s",
    ["publiser-place"] = "- %s",
    abstract = "> Abstract: %s",
  }
  return template[field] and string.format(template[field], str) or ""
end

M.format_entry = function(opts)
  if not opts.label then
    return nil
  end
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

---Normalize path
---@pram path string
---@return string
M.normalize_path = function(path)
  if not path:sub(1, 1) == "/" then
    return Path.new(vim.api.nvim_buf_get_name(0)):parent():joinpath(path):absolute()
  end
  return Path.new(path):expand()
end

---Read bibliography file
---@param url string
---@return string|nil
M.read_file = function(url)
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

M.nabla = function(str)
  if not nabla_avilable then
    return "nabla not found"
  end

  local nabla_latex_available, parser = pcall(require, "nabla.latex")
  local nabla_ascii_available, ascii = pcall(require, "nabla.ascii")

  if not nabla_latex_available or not nabla_ascii_available then
    return "error: nabla not found"
  end

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
