# Changelog

All notable changes to this project are documented here.

## [0.3.1] - 2026-11-09

Remote CI compatibility release.

### Fixed

- Add Vim 9.1 support with capability checks for OSC terminal events.
- Use a portable ASCII `listchars` fallback on older Vim builds and
  non-Unicode terminal environments.
- Keep Unicode markers as an explicit opt-in for Termux and compatible
  terminals.
- Avoid X display connection attempts during headless CI tests.
- Correct cross-process coverage aggregation for script-local functions.
- Validate the complete Unicode `listchars` set before selecting it.

### Verified

- GitHub Actions passes for Vim 9.1, 9.2, stable and nightly.
- C++ and Coc external integration jobs pass.
- 96.6% profiled line coverage.
- 100% function coverage (27/27).

## [0.3.0] - 2026-11-09

Terminal background synchronization.

### Added

- Query terminal background using Vim's `t_RB` and `v:termrbgresp`.
- Parse OSC 11 `rgb:` and `#rrggbb` background responses.
- Synchronize the terminal default background with the active JB editor
  background.
- Restore the original background when Vim exits, suspends, or switches to a
  different colour scheme.
- Reapply the background after `VimResume` and terminal background responses.
- `g:jb_manage_terminal_background` opt-out configuration.
- Unit and integration coverage for parsing, lifecycle and idempotency.

### Fixed

- Termux background-color-erase gaps no longer require editing
  `~/.termux/colors.properties`.
- Repeated `ColorScheme` and `TermResponseAll` events no longer emit duplicate
  background updates.

### Verified

- 95.9% profiled line coverage.
- 100% function coverage (25/25).
- Full unit and integration suite passes.

## [0.2.0] - 2026-11-09

L4 engineering baseline.

### Added

- GitHub Actions matrix for Vim 9.2, stable and nightly.
- Separate CI job for `vim-cpp-modern` and Coc integration.
- 256-colour fallback tests.
- Real Python, C++ and Markdown fixture tests.
- Dark and Light visual contract snapshots.
- Minimum feature checks for supported Vim builds.
- Release metadata consistency validation.
- Lint entry point for shell, JavaScript, JSON and release metadata.

### Verified

- Vim 9.2 with truecolor and 256-colour rendering.
- All local unit and integration suites pass.
- Optional `vim-cpp-modern` integration passes locally.
- Optional Coc integration passes locally.
- 98.6% profiled line coverage.
- 100% function coverage (14/14).

### Notes

- The GitHub Actions workflow is committed but cannot execute until this
  repository is pushed to a GitHub `origin`.
- Visual contracts are attribute snapshots, not pixel screenshots.

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
