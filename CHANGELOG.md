# Changelog

All notable changes to this project are documented here.

## [0.1.0] - 2026-11-09

Initial pre-release baseline for the maintained local derivative.

### Added

- Current JetBrains editor colours for background, foreground, caret row,
  visual selection, search, line numbers, brackets and completion panels.
- Configurable JetBrains-style whitespace markers with leading, inner,
  trailing, non-breaking-space and tab controls.
- Arrow, triangle, horizontal-line and hidden tab marker modes.
- Runtime whitespace commands: `JBWhitespaceOn`, `JBWhitespaceOff`,
  `JBWhitespaceToggle` and `JBWhitespaceStatus`.
- Markdown and text soft wrapping with a configurable continuation marker.
- Configurable right-margin guide.
- Current Markdown code block, inline code and blockquote styling.
- Italic documentation comments and constants.
- Unit and integration test suites using Vim's built-in assertions.
- Vim profiler coverage reporting with a 95% line and 100% function gate.
- Editor parity audit and detailed Vim compatibility documentation.

### Fixed

- `Normal` now explicitly uses the JetBrains editor background.
- Light mode no longer forces `background=dark`.
- Markdown headings no longer reference a missing `Const` highlight group.
- The `Added` diff group now references the correct JB gutter group.
- GUI errors now use undercurl instead of a plain underline.

### Verified

- Vim 9.2 with `+termguicolors`.
- 98.8% profiled line coverage.
- 100% function coverage (14/14).
- Clean unit and integration test run.

### Known limitations

- Selection-only whitespace visibility is not independently configurable.
- U+3000 ideographic space is not natively supported by `listchars`.
- Indent guides, sticky lines and breadcrumbs are outside this release.
- Neovim is not a supported target.
