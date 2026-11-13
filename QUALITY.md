# Quality baseline

This document defines the L4 acceptance criteria for this repository.

## Required gates

| Gate | Requirement | Local status |
| --- | --- | --- |
| Unit tests | Pure configuration and marker generation | Pass |
| Integration tests | Theme, Coc surface, wrapping, files and visual contracts | Pass |
| Coverage | At least 95% profiled lines and 100% functions | Pass |
| Lint | Shell, JavaScript, JSON and release metadata | Pass |
| Compatibility | Vim 9.1, 9.2, stable and nightly CI matrix | Pass |
| Colour modes | Truecolor and 256-colour fallback | Pass |
| External plugins | `vim-cpp-modern` and Coc | Pass |
| Converter | `.icls` parsing, reports, Vim loading and C++ mapping | Pass |
| Terminal background | OSC 11 apply and restore lifecycle | Pass |
| Release metadata | `VERSION`, README, CHANGELOG and Git tag | Pass |
| License | Repository-level MIT license | Pass |
| CI | GitHub Actions test and integration jobs | Pass |
| Visual regression | Dark and Light attribute snapshots | Pass |

## Compatibility matrix

| Environment | Purpose | Local | CI |
| --- | --- | --- | --- |
| Vim 9.2.1178 | Current development environment | Pass | Pass |
| Vim v9.1.0000 | Minimum supported release | Not installed | Pass |
| Vim v9.2.0000 | Vim 9.2 baseline release | Not installed | Pass |
| Vim stable | Latest stable release | Same local line | Pass |
| Vim nightly | Forward compatibility | Not installed | Pass |
| Vim + `vim-cpp-modern` | External syntax compatibility | Pass | Pass |
| Generated scheme + `vim-cpp-modern` | Imported theme preserves C++ links | Pass | Pass |
| Vim + Coc | Completion plugin highlight compatibility | Pass | Pass |
| Termux OSC 11 | Background synchronization and restore | Pass by fake emitter tests | Device verification |

## Remaining non-blocking gaps

- Visual snapshots validate highlight attributes, not terminal pixels.
- Branch coverage is not reported because Vim does not expose a reliable
  native branch coverage format.
- Neovim is outside the supported target for this release.
- Indent guides, sticky lines and breadcrumbs are outside the current release
  scope.
