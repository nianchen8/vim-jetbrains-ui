# JetBrains .icls to Vim conversion contract

## Scope

`tools/jb_convert.py` converts the editor color-scheme portion of a JetBrains
`.icls` file to a standalone traditional Vim color scheme.

It intentionally does not convert:

- the JetBrains window/interface theme;
- icons, typography, spacing, or editor behavior;
- every language-specific JetBrains attribute;
- symbol semantics that a Vim syntax plugin cannot provide.

The converter is a semantic projection layer. It does not maintain a fixed
color palette. Colors come from the input scheme.

## Pipeline

```text
.icls XML
  -> local baseAttributes resolution
  -> normalized JetBrains attributes
  -> canonical syntax roles
  -> Vim highlight projection
  -> generated colorscheme and JSON report
```

The canonical roles include identifier, local variable, parameter, field,
static field, function, method, type, namespace, keyword, preprocessor,
macro, constant, string, number, comment, and operator.

JetBrains-specific `OC.*` attributes take precedence when present. Missing
language-specific values fall back to `DEFAULT_*` roles and finally to the
identifier or editor text style.

## Current limitations

### Parent schemes

An `.icls` export can omit attributes inherited from its `parent_scheme`.
This version resolves only `baseAttributes` references inside the selected
file. Missing `DEFAULT_*` or `OC.*` inputs use semantic fallbacks and are
recorded in the JSON report.

Resolving complete parent-scheme chains is a future extension.

### Vim syntax capability

The generated scheme maps `vim-cpp-modern` groups, including:

```text
cUserFunction       cStructMember       cTypeName
cppSTLnamespace     cppSTLvariable      cppSTLios
cppSTLfunction      cppSTLtype          cppSTLtypedef
cppSTLconstant      cppSTLbool          cppSTLexception
cppExceptions       cppBoolean          cppStatement
```

Regular expressions cannot identify every local variable, parameter, field,
or method with the same precision as a C++ semantic engine. The generated
theme provides JetBrains-compatible colors for the tokens that Vim syntax
plugins can classify.

### UI coverage

The converter maps the editor background, caret row, line numbers,
selection, search, whitespace, indent guide, right margin, matched brace,
diagnostics, hyperlinks, and popup background when those values are present.

JetBrains chrome and navigation surfaces are outside the `.icls` contract.

## Determinism and validation

The generated Vim file and JSON report are deterministic for the same input.
Tests cover:

- local attribute inheritance;
- missing `baseAttributes` reporting;
- generated generic and C/C++ highlight links;
- truecolor-style conversion and 256-colour output;
- loading the generated scheme in Vim and resolving C++ groups.

Run the converter tests with:

```sh
python3 -m unittest discover -s test -p 'test_*.py' -v
```
