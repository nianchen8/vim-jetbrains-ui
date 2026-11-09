<div align="center">
    <img src="assets/logo.png" width="75" alt="Logo"/>
    <h3>JB for Vim</h3>
    <p>JetBrains editor visual compatibility for traditional Vim.</p>
    <p><strong>Version 0.1.0 · Pre-release</strong></p>
</div>

![Theme Screenshot](assets/screenshot.png)

Version
---------------------------------------------------------------------------

This repository is a maintained derivative of
[`devsjc/vim-jb`](https://github.com/devsjc/vim-jb). Version `0.1.0`
establishes the current JetBrains editor-visual baseline.

The palette was checked against the IntelliJ Platform 2026.3 editor source.
The project targets traditional Vim and has been tested with Vim 9.2.

See [CHANGELOG.md](CHANGELOG.md) for the exact scope of this version.

Highlights
---------------------------------------------------------------------------

- Current JetBrains Dark, Light and Mid syntax palettes.
- Current editor background, caret row, selection, search and line-number
  colours.
- Configurable JetBrains-style spaces, tabs, non-breaking spaces and right
  margin.
- Configurable soft wrapping for Markdown and text files.
- Current Markdown code block, inline code and blockquote styling.
- Italic documentation comments and constants.
- Highlight links for GitGutter, NERDTree, FZF, ALE, Coc, Fern, Fugitive and
  other common Vim plugins.
- Truecolor, 256-colour, italic and Unicode support.
- Palette-level colour overrides.

Installation
---------------------------------------------------------------------------

Install this repository with vim-plug:

```vim
Plug '~/Projects/vim-jb'
```

For a different checkout location, replace the path with the absolute path to
this repository. The plugin is intentionally installed as a local Vim plugin;
it is not loaded from a second copy under `~/.vim/plugged`.

A complete example:

```vim
call plug#begin('~/.vim/plugged')
Plug '~/Projects/vim-jb'

let g:jb_style = 'dark'
let g:jb_enable_italic = 1
let g:jb_enable_unicode = 1
let g:jb_whitespace = {
      \ 'enabled': 1,
      \ 'leading': 1,
      \ 'inner': 1,
      \ 'trailing': 1,
      \ 'nbsp': 1,
      \ 'tab': 'arrow',
      \ }
let g:jb_soft_wrap = {
      \ 'enabled': 1,
      \ 'filetypes': ['markdown', 'text'],
      \ 'showbreak': '↳ ',
      \ }
let g:jb_right_margin = 120

call plug#end()

if has('termguicolors')
  set termguicolors
endif
colorscheme jb
```

Configuration options must be set before the plugin is loaded. With vim-plug,
place them before `call plug#end()`.

Whitespace controls
---------------------------------------------------------------------------

JetBrains exposes leading, inner, trailing and selection whitespace as separate
settings. Vim can reproduce the first three independently through `listchars`.
Selection-only whitespace control is not available in Vim's native renderer.

```vim
let g:jb_whitespace = {
      \ 'enabled': 1,
      \ 'leading': 1,
      \ 'inner': 1,
      \ 'trailing': 1,
      \ 'nbsp': 1,
      \ 'tab': 'arrow',
      \ }
```

Supported tab styles:

- `arrow`: `→ `
- `triangle`: `▸ `
- `line`: `─ `
- `none`: hidden marker

Runtime commands:

```vim
:JBWhitespaceOn
:JBWhitespaceOff
:JBWhitespaceToggle
:JBWhitespaceStatus
```

Editor helpers
---------------------------------------------------------------------------

The companion plugin configures the current-line highlight, a right margin and
optional soft wrapping:

```vim
let g:jb_cursorline = 1
let g:jb_right_margin = 120
let g:jb_soft_wrap = {
      \ 'enabled': 1,
      \ 'filetypes': ['markdown', 'text'],
      \ 'showbreak': '↳ ',
      \ }
```

See `:help jb-configuration` after generating help tags for the complete option
reference.

Colour overrides
---------------------------------------------------------------------------

Pick a category from [autoload/palettes.json](autoload/palettes.json) and
override its GUI and terminal colours:

```vim
let g:jb_color_overrides = {
      \ 'keyword': {'gui': '#ff00ff', 'cterm': 201},
      \ 'type': {'gui': '#00ff00', 'cterm': 46},
      \ }
```

Highlight links can be replaced from a `ColorScheme` autocmd:

```vim
augroup JBHighlights
    autocmd!
    autocmd ColorScheme * highlight link ktStructure Type
augroup END
```

Testing
---------------------------------------------------------------------------

Run all unit and integration tests:

```sh
./test/run.sh
```

Run Vim's profiler and enforce the coverage gate:

```sh
./test/coverage.sh
```

Version `0.1.0` test status:

```text
Unit suites:          1
Integration suites:   5
Profiled line cover:  98.8%
Function coverage:    100% (14/14)
Coverage gate:        >= 95% lines and 100% functions
```

The coverage report uses Vim's built-in `+profile` feature. Branch coverage is
not claimed because Vim does not provide a reliable native branch-coverage
report.

Compatibility and limitations
---------------------------------------------------------------------------

- Target: traditional Vim; Vim 9.2 is the tested environment.
- Neovim is not a supported target for this release.
- Truecolor is recommended. A 256-colour fallback remains available.
- Terminal fonts, ligatures, line height and cursor animation are controlled by
  the terminal emulator, not by this plugin.
- Vim cannot independently toggle whitespace only inside a visual selection.
- U+3000 ideographic spaces cannot be rendered through native `listchars`.
- Space dots and tab arrows are terminal glyph approximations of JetBrains'
  vector renderer.
- Indent guides, sticky lines and breadcrumbs require additional plugins or a
  future renderer layer.
- Smooth caret movement and animated scrolling cannot be provided by a Vim
  colour scheme.

The detailed feature boundary is recorded in
[doc/editor-parity.md](doc/editor-parity.md).

Upstream
---------------------------------------------------------------------------

- Original project: <https://github.com/devsjc/vim-jb>
- Git remote name: `upstream`
- Current local branch: `main`

Related terminal themes:

- [terminals-jb](https://github.com/devsjc/terminals-jb)

License
---------------------------------------------------------------------------

MIT. See [LICENSE](LICENSE).
