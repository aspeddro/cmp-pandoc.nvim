local Job = require("plenary.job")
local utils = require("cmp_pandoc.utils")

local M = {}

M.parse_from_cli = function(path, callback)
  Job
    :new({
      command = "pandoc",
      args = {
        path,
        "--standalone",
        "--from",
        "bibtex",
        "--to",
        "csljson",
      },
      on_exit = vim.schedule_wrap(function(job, code)
        if code ~= 0 then
          vim.notify(string.format("[cmp-pandoc]: Job returned with exit code %d", code), vim.log.levels.WARN, {
            title = "cmp-pandoc",
          })
        else
          local result = table.concat(job:result(), "")

          local ok, decode = pcall(vim.json.decode, result)

          if not ok then
            vim.notify("[cmp-pandoc]: Failed to decode pandoc result", vim.log.levels.ERROR, {
              title = "cmp-pandoc",
            })
            callback()
          end

          callback(decode)
        end
      end),
    })
    :start()
end

M.parse_from_file = function(path, opts, callback)
  local data = utils.read_file(path)

  if not data then
    callback()
  end

  local o = {}

  for citation in data:gmatch("@.-\n}") do
    table.insert(o, citation)
  end

  local result = vim.tbl_map(function(citation)
    local documentation = vim.tbl_map(function(field)
      return utils.format(citation, field)
    end, { "type", "title", "author", "year" })

    return utils.format_entry({
      label = citation:match("@%w+{(.-),"),
      doc = opts.documentation,
      kind = "Field",
      value = table.concat(documentation, "\n"),
    })
  end, o)

  callback(result)
end

return M
