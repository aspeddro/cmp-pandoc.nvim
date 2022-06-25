local async = require("plenary.async.async")
local utils = require("cmp_pandoc.utils")
local bibliography = require("cmp_pandoc.parsers.bibliography")
local crossref = require("cmp_pandoc.parsers.crossref")
local yaml = require("cmp_pandoc.parsers.yaml_front_matter")
local literals = require("cmp_pandoc.literals")

local M = {}

---Citations
---@param lines string[]
---@param opts table
---@return table|nil
M.bibliography = async.wrap(function(lines, opts, callback)
  local yaml_front_matter = yaml.parse(lines)

  if not yaml_front_matter then
    return callback()
  end

  local all_bib_entrys = {}

  for _, path in ipairs(yaml_front_matter) do
    if vim.fn.executable("pandoc") == 1 then
      bibliography.parse_from_cli(utils.normalize_path(path), function(result)
        for _, entry in ipairs(result) do
          local format_fields = vim.tbl_map(function(field)
            local o = {}
            if field == "author" and entry[field] then
              o[1] = field
              o[2] = table.concat(
                vim.tbl_map(function(author)
                  return string.format("%s, %s", author.family, author.given)
                end, entry[field]),
                " and "
              )
            else
              if entry[field] then
                o[1] = field
                o[2] = vim.trim(entry[field])
              end
            end
            return o
          end, opts.fields)

          local doc = vim.tbl_map(
            function(f)
              return utils.format_from_cli(f[2], f[1])
            end,
            vim.tbl_filter(function(f)
              return f[2] ~= nil
            end, format_fields)
          )

          table.insert(all_bib_entrys, {
            label = "@" .. entry.id,
            documentation = {
              value = table.concat(doc, "\n"),
              kind = "markdown",
            },
          })
        end
        callback(all_bib_entrys)
      end)
    else
      bibliography.parse_from_file(utils.normalize_path(path), opts, function(result)
        if result then
          vim.list_extend(all_bib_entrys, result)
          -- table.insert(all_bib_entrys, result)
        end
        callback(all_bib_entrys)
      end)
    end
  end
end, 3)

---Get cross references
---@param lines string[]
---@param opts table
---@return table|nil
M.crossref = async.wrap(function(lines, opts, callback)
  local valid_lines = vim.tbl_filter(function(line)
    return line:match(literals.crossref_patterns.base) and not line:match("^%<!%-%-(.*)%-%-%>$")
  end, lines)

  if vim.tbl_isempty(valid_lines) then
    return callback()
  end

  local result = vim.tbl_map(function(line)
    return crossref.handle(line, opts)
  end, valid_lines)
  callback(result)
end, 3)

M.init = async.void(function(self, callback, bufnr)
  local opts = self and self.opts or require("cmp_pandoc.config")
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)

  if vim.tbl_isempty(lines) then
    return callback()
  end

  local items = {}

  local bibliography_items = M.bibliography(lines, opts.bibliography)
  local crossref_items = M.crossref(lines, opts.crossref)

  if bibliography_items then
    vim.list_extend(items, bibliography_items)
  end

  if crossref_items then
    vim.list_extend(items, crossref_items)
  end

  callback({ items = items })
end)

return M
