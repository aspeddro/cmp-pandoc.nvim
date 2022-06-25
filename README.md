# cmp-pandoc

Pandoc source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

## Screenshots

<table>
  <tr>
    <td>Bibliography</td>
    <td>CrossRef</td>
  </tr>
  <tr>
    <td><img src="https://user-images.githubusercontent.com/16160544/162342857-277c4c26-4e7f-4174-81d5-a2b5b75e12fd.png"></td>
    <td><img src="https://user-images.githubusercontent.com/16160544/162342939-6f0d3672-fcf6-4d7b-a5b8-d1ddc5227f20.png"></td>
  </tr>
</table>

## Requirements

- `Neovim >= 0.7.0`
- [`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim)

## Features

- Multiple bibliography files
- Support [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref)
- Equation preview with [`nabla.nvim`](https://github.com/jbyuki/nabla.nvim)

## Installation

[*packer.nvim*](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'aspeddro/cmp-pandoc.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'jbyuki/nabla.nvim' -- optional
  }
}
```

[*vim-plug*](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'jbyuki/nabla.nvim' "optional
Plug 'aspeddro/cmp-pandoc.nvim'
```

## Setup

```lua
require'cmp'.setup{
  sources = {
    { name = 'pandoc' }
  }
}
require'cmp_pandoc'.setup()
```

## Configuration (optional)

Following are the default config for the `setup()`. If you want to override, just modify the option that you want then it will be merged with the default config.

```lua
{
  -- What types of files cmp-pandoc works.
  -- 'pandoc', 'markdown' and 'rmd' (Rmarkdown)
  -- @type: table of string
  filetype = { "pandoc", "markdown", "rmd" },
  -- Customize bib documentation
  bibliography = {
    -- Enable bibliography documentation
    -- @type: boolean
    documentation = true,
    -- Fields to show in documentation
    -- @type: table of string
    fields = { "type", "title", "author", "year" },
  },
  -- Crossref
  crossref = {
    -- Enable documetation
    -- @type: boolean
    documentation = true,
    -- Use nabla.nvim to render LaTeX equation to ASCII
    -- @type: boolean
    enable_nabla = false,
  }
}
```

## Basic Syntax

Add bibliography file on YAML Header

```yaml
---
bibliography: path/to/references.bib
---
```

Multiple bibliography files:
```yaml
---
bibliography:
- path/to/references.bib
- path/to/other/references.bib
---
```

> A YAML metadata block is a valid YAML object, delimited by a line of three hyphens `---` at the top and a line of three hyphens `---` or three dots `...` at the bottom. A YAML metadata block may occur anywhere in the document, but if it is not at the beginning, it must be preceded by a blank line. [Pandoc.org](https://pandoc.org/MANUAL.html#extension-yaml_metadata_block)

More details, see [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/)

## Limitations

- YAML metadata inside code blocks with `bibliography` field enable `cmp-pandoc`. The parser does not check if it is inside a fenced code block.
- Pandoc crossref support a couple options to add code block labels, but only the following style is supported:

  ~~~ 
  ```haskell
  main :: IO ()
  main = putStrLn "Hello World!"
  ```

  : Listing caption {#lst:code}
  ~~~

## Recomendations

- [pandoc.nvim](https://github.com/aspeddro/pandoc.nvim)

## Alternatives

- [cmp-pandoc-references](https://github.com/jc-doyle/cmp-pandoc-references/)
