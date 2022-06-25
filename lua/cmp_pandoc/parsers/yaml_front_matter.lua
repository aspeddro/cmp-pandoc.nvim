local M = {}

--- Get bibliography paths
---@param lines string[]
---@return string[]|nil
M.get_bibliography_paths = function(lines)
  local front_matter = M.yaml_front_matter(lines)

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

--- YAML Front Matter
---@param lines string[]
---@return table
M.parse = function(lines)
  local yaml_start = nil
  local yaml_end = nil

  local function is_valid_delimiter(str)
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
    if string.match(lines[i], "^%-%-%-") and is_valid_delimiter(lines[i]) and not yaml_start then
      yaml_start = i
      i = i + 1
    end
    if is_valid_delimiter(lines[i]) then
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

  if not is_valid_yaml then
    return
  end

  local yaml_content = vim.list_slice(lines, yaml_start + 1, yaml_end - 1)

  local bibliography_line = nil

  for index, value in ipairs(yaml_content) do
    if string.match(value, "^bibliography:") then
      bibliography_line = index
      break
    end
  end

  if not bibliography_line then
    return
  end

  local bibliography_field = vim.trim(string.match(yaml_content[bibliography_line], ":(.*)"))

  if string.len(bibliography_field) > 0 then
    return { bibliography_field }
  end

  local bibliography_inputs = {}

  local ii = 1

  while i <= #yaml_content do
    if string.match(yaml_content[i], "^%-%s[%w|%d|%D]+") then
      table.insert(bibliography_inputs, yaml_content[i])
    end
    ii = ii + 1
  end

  if #bibliography_inputs == 0 then
    return
  end

  return vim.tbl_map(function(bibliography)
    return vim.trim(string.match(bibliography, "-%s(.*)"))
  end, bibliography_inputs)

  -- return {
  --   is_valid = is_valid_yaml,
  --   start = yaml_start,
  --   ["end"] = yaml_end,
  --   raw_content = is_valid_yaml and vim.list_slice(lines, yaml_start + 1, yaml_end - 1) or nil,
  -- }
end

return M
