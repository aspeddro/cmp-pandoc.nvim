local M = {}

M.crossref_patterns = {
  base = "{#(%a+:[%w_-]+)",
  equation = "{#(eq:[%w_-]+)",
  section = "{#(sec:[%w_-]+)",
  figure = "{#(fig:[%w_-]+)",
  table = "{#(tbl:[%w_-]+)",
  lst = "{#(lst:[%w_-]+)",
}

M.bib_patterns = {
  id = "@%w+{(.-),",
  type = "@(%w+)",
  title = "title%s*=%s*[{]*(.-)[}],",
  author = 'author%s*=%s*["{]*(.-)["}],?',
  year = 'year%s*=%s*["{]?(%d+)["}]?,?',
}

return M
