# JetBrains → Vim editor parity audit

Status: research baseline, 2026-11-09.

This document records the visual and behavioural surface we intend to reproduce.
It is not a claim that Vim can reproduce every IntelliJ Platform feature.

## 1. What "show whitespaces" means

The dots are not a colour-scheme-only feature. They belong to the editor
renderer. JetBrains exposes one master setting and four independent scopes:

- Leading whitespace
- Inner whitespace
- Trailing whitespace
- Whitespace inside the current selection

The renderer currently handles three characters as visually shown whitespace:

- U+0020 SPACE
- U+0009 TAB
- U+3000 IDEOGRAPHIC SPACE

Space is rendered as a small centred vector dot. It is not the font glyph
`·`. Tabs are rendered as an arrow or horizontal line according to the editor
setting. Ideographic spaces are rendered as a box. Space and ideographic-space
colour comes from `WHITESPACES_COLOR`. Tab colour can come from `TABS_COLOR`.

Consequences for Vim:

- `list` is the master switch.
- `listchars` provides the glyph approximation.
- `SpecialKey` colours space, tab, nbsp, lead and trail markers.
- `NonText` colours eol, extends and precedes markers.
- Vim cannot vector-draw a font-independent dot; a terminal glyph must be used.
- Vim has no independent "selected whitespace only" switch.
- Vim does not natively distinguish U+3000 with `listchars`.
- Tab markers can be approximated as `→` or `▸`, but not JetBrains' exact
  painted arrow.

These four JetBrains scopes map approximately to Vim:

| JetBrains | Vim approximation |
| --- | --- |
| Leading | `lead`, `leadmultispace`, `leadtab` |
| Inner | `space`, `multispace` |
| Trailing | `trail` |
| Selection | no independent switch; normal list rendering remains visible |
| Tab | `tab`, `leadtab` |
| Non-breaking space | `nbsp` |
| Ideographic space | custom syntax/match support only |

## 2. Scope across JetBrains products

This is shared IntelliJ Platform editor behaviour, not PyCharm-only behaviour.
PyCharm was only an example where the feature was first noticed. The same editor
surface appears across IntelliJ IDEA, PyCharm, WebStorm, PhpStorm, GoLand,
CLion, RubyMine, DataGrip, Android Studio and other IntelliJ-based products.

JetBrains itself separates three concepts:

1. UI theme: windows, dialogs, controls, tool windows.
2. Editor colour scheme: code, gutter, selections, hints and diagnostics.
3. Editor settings: whitespace, caret, scrolling, wrapping and line numbers.

Our Vim project must keep the same separation. A colour scheme alone cannot
change editor behaviour.

## 3. Editor display inventory

### P0: core visual parity

- Editor background and foreground.
- Syntax token colours and font styles.
- Caret-row background.
- Current selection background.
- Search and current-search highlighting.
- Occurrences of selected text.
- Matched and unmatched brackets.
- Line numbers and line number on the caret row.
- Gutter background and VCS change markers.
- Visible leading, inner and trailing whitespace.
- Tab and non-breaking-space markers.
- Right margin / visual guide.

### P1: structural editor decoration

- Indent guides.
- Current indentation guide emphasis.
- Code-folding markers and fold region appearance.
- Soft-wrap markers.
- More-indicator characters for hidden text.
- Inlay hints and inline parameter hints.
- Diagnostics: undercurl, background, gutter sign and virtual text.
- Diff backgrounds: added, changed, changed text and deleted.
- Method separators.
- Current-line and selection behaviour during scrolling.

### P2: navigation chrome and IDE-like assistance

- Breadcrumbs.
- Sticky lines.
- Code lens on scrollbar hover.
- Intention bulb and quick-fix indicators.
- Breakpoints, bookmarks and coverage markers.
- Git blame and VCS annotation gutter.
- Documentation-comment rendering and links.
- HTML/XML tag hierarchy highlighting.
- CSS colour previews.

### P3: renderer/terminal-dependent behaviour

- Smooth caret movement and easing.
- Smooth caret blinking and rounded caret.
- Block and full-line-height caret behaviour.
- Animated scrolling.
- Variable editor line height.
- Font ligatures and OpenType character variants.
- Subpixel/vector-rendered whitespace dots and tabs.

These can be approximated through terminal configuration or plugins, but not
fully reproduced by a Vim colour scheme.

## 4. Vim implementation layers

| Layer | Responsible for |
| --- | --- |
| `colors/jb.vim` | Colour scheme and highlight-group semantics |
| `plugin/` | Optional editor options, autocmds and Vim UI helpers |
| `autoload/` | Palette/configuration APIs and reusable logic |
| `.vimrc` | User choices such as whitespace visibility and line-number mode |
| Coc | LSP diagnostics, inlay hints, completion and semantic information |
| Terminal emulator | Font, ligatures, line height, cursor and colour support |
| Auxiliary Vim plugins | Indent guides, sticky navigation, breadcrumbs, etc. |

## 5. Local implementation status

Implemented in the local branch:

- Current JetBrains editor background, foreground, caret row and selection.
- Current ordinary and caret-row line-number colours.
- Current whitespace colour (`WHITESPACES_COLOR`).
- Configurable leading, inner and trailing whitespace.
- Configurable arrow, triangle, horizontal-line and hidden tab markers.
- Current matched-brace and right-margin colours.
- Current Markdown code block/span background.
- Markdown heading and FZF header no longer reference a missing `Const` group.
- Documentation comments and constants use JetBrains italic styling.
- Light mode now selects `background=light`.
- Markdown/text soft wrapping with a visible continuation marker.
- A configurable right margin.

Remaining approximations and gaps:

- Whitespace inside a selection cannot be toggled independently.
- U+3000 IDEOGRAPHIC SPACE is not natively distinguishable by `listchars`.
- Space dots and tab arrows are terminal glyph approximations of JetBrains'
  vector drawing.
- Indent guides require a separate Vim plugin or a future renderer layer.
- Smooth caret movement, animated scrolling and variable line height cannot be
  provided by the colour scheme.
- Python decorator colour still uses the generic Tag group.

## 6. Source references

- JetBrains editor appearance:
  https://www.jetbrains.com/help/idea/settings-editor-appearance.html
- JetBrains editor general settings:
  https://www.jetbrains.com/help/idea/settings-editor-general.html
- JetBrains colour schemes and fonts:
  https://www.jetbrains.com/help/idea/configuring-colors-and-fonts.html
- JetBrains editor gutter:
  https://www.jetbrains.com/help/idea/editor-gutter.html
- IntelliJ `LineWhitespacePaintingStrategy`:
  https://github.com/JetBrains/intellij-community/blob/master/platform/platform-impl/src/com/intellij/openapi/editor/impl/view/LineWhitespacePaintingStrategy.java
- IntelliJ `EditorPainter` whitespace renderer:
  https://github.com/JetBrains/intellij-community/blob/master/platform/platform-impl/src/com/intellij/openapi/editor/impl/view/EditorPainter.java
- Current Dark editor scheme:
  https://github.com/JetBrains/intellij-community/blob/master/platform/platform-resources/src/themes/expUI/expUI_darkScheme.xml
