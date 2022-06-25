local M = {}

---@class BibliographyOptions
---@field documentation boolean
---@field fields string[]

---@class CrossrefOptions
---@field documentation boolean
---@field enable_nabla boolean

---@class Options cmp-pandoc default options
---@field filetypes string[] filetypes to enable pandoc
---@field keyword_pattern string
---@field bibliography BibliographyOptions
---@field crossref CrossrefOptions

---@type Options
M = {
  filetype = { "pandoc", "markdown", "rmd" },
  keyword_pattern = "[@][^[:blank:]]*",
  bibliography = {
    documentation = true,
    fields = {
      "type",
      "title",
      "author",
      "year",
      "container-title",
      "page",
      "volume",
      "edition",
      "DOI",
      "URL",
      "issue",
      "publiser",
      "publiser-place",
      "abstract",
    },
  },
  crossref = {
    documentation = true,
    enable_nabla = false,
  },
}

return M
