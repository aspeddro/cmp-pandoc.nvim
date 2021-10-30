# cmp-pandoc

Pandoc source for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)

![image](https://user-images.githubusercontent.com/16160544/139517208-ca327374-9808-479d-9005-3b7ae0541202.png)

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
    { name = 'cmp_pandoc' },
  }
}
require'cmp_pandoc'.setup()
```

#### Options

- `filetypes` (table): list of fileypes to enable completion
- `bibliography` (table):
  - `documetation` (boolean): enable documetation
  - `fields` (table): fiels of bib file to show in documentation
- `crossref` (table):
  - `documentation` (boolean): enable documentation
  - `enable_nabla` (boolean): use [`nabla.nvim`](https://github.com/jbyuki/nabla.nvim) to show LaTeX equation

Default configuration:

```lua
filetypes = {'pandoc', 'markdown', 'rmd'},
bibliography = {
  documentation = true,
  fields = { 'type', 'title', 'author', 'year' },
},
crossref = {
  documentation = true,
  enable_nabla = true
}
```

## TODO

- [x] references fields to show
- [x] equation preview completion
- [x] support pandoc-crossref
- [ ] use plenary async (fix [252](https://github.com/nvim-lua/plenary.nvim/issues/252))

## Acknowledgement

- [cmp-pandoc-references](https://github.com/jc-doyle/cmp-pandoc-references/)
