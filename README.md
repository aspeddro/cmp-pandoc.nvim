# cmp-pandoc

Pandoc source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

![image](https://user-images.githubusercontent.com/16160544/139517208-ca327374-9808-479d-9005-3b7ae0541202.png)
![image](https://user-images.githubusercontent.com/16160544/139517577-72a8025d-ce44-4923-8249-ad1b7a5b41cd.png)

## Requirements

- `Neovim >= 0.5.0`
- [`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim)

## Features

- Multiple `bib` files
- Support [pandoc-crossref](https://github.com/lierdakil/pandoc-crossref)
- Equation preview with [`nabla.nvim`](https://github.com/jbyuki/nabla.nvim)

## Installation

#### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'aspeddro/cmp-pandoc.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'jbyuki/nabla.nvim' -- optional
  }
}
```

#### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'jbyuki/nabla.nvim' "optional
Plug 'aspeddro/cmp-pandoc.nvim'
```

## Setup

```lua
require'cmp'.setup{
  sources = {
    { name = 'cmp_pandoc' }
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
  filetypes = { "pandoc", "markdown", "rmd" },
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
bibliography: path/to/bibfile.bib
---
```

Multiple bibliography files:
```yaml
---
bibliography:
- path/to/bibfile.bib
- path/to/otherbibfile.bib
---
```

> A YAML metadata block is a valid YAML object, delimited by a line of three hyphens `---` at the top and a line of three hyphens `---` or three dots `...` at the bottom. A YAML metadata block may occur anywhere in the document, but if it is not at the beginning, it must be preceded by a blank line. [Pandoc.org](https://pandoc.org/MANUAL.html#extension-yaml_metadata_block)

Whitespace after `---` or `...` is not supported. This plugin uses the buffer path as the working directory.

More details, see [pandoc-crossref](https://lierdakil.github.io/pandoc-crossref/)

## Recomendations

- [pandoc.nvim](https://github.com/aspeddro/pandoc.nvim)

## TODO

- [x] references fields to show
- [x] equation preview completion
- [x] support pandoc-crossref
- [ ] support whitespace after `---` or `...`
- [ ] Documentation table and code blocks
- [ ] Disable in codeblocks
- [ ] use plenary async (fix [252](https://github.com/nvim-lua/plenary.nvim/issues/252))

## Alternatives

- [cmp-pandoc-references](https://github.com/jc-doyle/cmp-pandoc-references/)
