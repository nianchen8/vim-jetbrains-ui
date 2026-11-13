#!/usr/bin/env python3
"""Convert a JetBrains editor color scheme (.icls) to a Vim color scheme."""

from __future__ import annotations

import argparse
import json
import re
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable


class ConversionError(Exception):
    """Raised when an input scheme cannot be converted."""


@dataclass
class RawAttribute:
    base: str | None = None
    values: dict[str, str] = field(default_factory=dict)


@dataclass
class Scheme:
    name: str
    version: str | None
    parent: str | None
    metadata: dict[str, str]
    colors: dict[str, str]
    raw_attributes: dict[str, RawAttribute]
    attributes: dict[str, dict[str, str]] = field(default_factory=dict)
    unresolved: list[dict[str, str]] = field(default_factory=list)


@dataclass
class Role:
    sources: list[str]
    attribute: dict[str, str]
    inherited_from: list[str]


ROLE_SOURCES = {
    "identifier": (
        "OC.IDENTIFIER",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "local_variable": (
        "OC.LOCAL_VARIABLE",
        "DEFAULT_LOCAL_VARIABLE",
        "LOCAL_VARIABLE_ATTRIBUTES",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "parameter": (
        "OC.PARAMETER",
        "DEFAULT_PARAMETER",
        "PARAMETER_ATTRIBUTES",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "field": (
        "OC.STRUCT_FIELD",
        "DEFAULT_INSTANCE_FIELD",
        "INSTANCE_FIELD_ATTRIBUTES",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "static_field": (
        "OC.STATIC_FIELD",
        "DEFAULT_STATIC_FIELD",
        "STATIC_FIELD_ATTRIBUTES",
        "OC.STRUCT_FIELD",
        "DEFAULT_INSTANCE_FIELD",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "function": (
        "OC.FUNCTION",
        "DEFAULT_FUNCTION_DECLARATION",
        "OC.METHOD",
        "DEFAULT_FUNCTION_CALL",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "function_call": (
        "DEFAULT_FUNCTION_CALL",
        "OC.FUNCTION",
        "DEFAULT_FUNCTION_DECLARATION",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "method": (
        "OC.METHOD",
        "DEFAULT_INSTANCE_METHOD",
        "DEFAULT_STATIC_METHOD",
        "DEFAULT_FUNCTION_DECLARATION",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "type": (
        "OC.STRUCT_LIKE",
        "OC.TEMPLATE_TYPE",
        "OC.CPP_ALIAS",
        "OC.TYPEDEF",
        "DEFAULT_PREDEFINED_SYMBOL",
        "DEFAULT_CLASS_NAME",
        "DEFAULT_KEYWORD",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "namespace": (
        "OC.NAMESPACE_LIKE",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "keyword": (
        "OC.KEYWORD",
        "OC.CPP_KEYWORD",
        "DEFAULT_KEYWORD",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "preprocessor": (
        "OC.DIRECTIVE",
        "OC.KEYWORD",
        "OC.CPP_KEYWORD",
        "DEFAULT_KEYWORD",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "macro": (
        "OC.MACRONAME",
        "OC.DIRECTIVE",
        "DEFAULT_METADATA",
        "DEFAULT_KEYWORD",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "enum": (
        "OC.ENUM_CONST",
        "DEFAULT_CONSTANT",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "label": (
        "OC.LABEL",
        "DEFAULT_LABEL",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "constant": (
        "DEFAULT_CONSTANT",
        "OC.ENUM_CONST",
        "DEFAULT_IDENTIFIER",
        "TEXT",
    ),
    "string": (
        "OC.STRING",
        "DEFAULT_STRING",
        "TEXT",
    ),
    "number": (
        "OC.NUMBER",
        "DEFAULT_NUMBER",
        "TEXT",
    ),
    "comment": (
        "OC.LINE_COMMENT",
        "DEFAULT_LINE_COMMENT",
        "DEFAULT_BLOCK_COMMENT",
        "TEXT",
    ),
    "doc_comment": (
        "DEFAULT_DOC_COMMENT",
        "DEFAULT_LINE_COMMENT",
        "DEFAULT_BLOCK_COMMENT",
        "TEXT",
    ),
    "doc_tag": (
        "DEFAULT_DOC_COMMENT_TAG",
        "DEFAULT_DOC_COMMENT",
        "DEFAULT_LINE_COMMENT",
        "TEXT",
    ),
    "operator": (
        "OC.OPERATION_SIGN",
        "DEFAULT_OPERATION_SIGN",
        "TEXT",
    ),
}


ATTRIBUTE_ROLES = {
    "error": ("ERRORS_ATTRIBUTES",),
    "warning": ("WARNING_ATTRIBUTES",),
    "todo": ("TODO_DEFAULT_ATTRIBUTES",),
    "hyperlink": ("HYPERLINK_ATTRIBUTES", "FOLLOWED_HYPERLINK_ATTRIBUTES"),
    "folded": ("FOLDED_TEXT_ATTRIBUTES",),
    "matched_brace": ("MATCHED_BRACE_ATTRIBUTES",),
    "search": ("SEARCH_RESULT_ATTRIBUTES",),
    "search_current": ("TEXT_SEARCH_RESULT_ATTRIBUTES",),
}


COLOR_ROLES = {
    "caret": ("CARET_COLOR",),
    "caret_row": ("CARET_ROW_COLOR",),
    "line_number": ("LINE_NUMBERS_COLOR",),
    "line_number_current": ("LINE_NUMBER_ON_CARET_ROW_COLOR",),
    "whitespace": ("WHITESPACES",),
    "indent_guide": ("INDENT_GUIDE",),
    "right_margin": ("RIGHT_MARGIN_COLOR",),
    "selection_background": ("SELECTION_BACKGROUND",),
    "selection_foreground": ("SELECTION_FOREGROUND",),
    "popup_background": ("LOOKUP_COLOR",),
}


VIM_ROLE_NAMES = {
    "identifier": "JBImportedIdentifier",
    "local_variable": "JBImportedLocalVariable",
    "parameter": "JBImportedParameter",
    "field": "JBImportedField",
    "static_field": "JBImportedStaticField",
    "function": "JBImportedFunction",
    "function_call": "JBImportedFunctionCall",
    "method": "JBImportedMethod",
    "type": "JBImportedType",
    "namespace": "JBImportedNamespace",
    "keyword": "JBImportedKeyword",
    "preprocessor": "JBImportedPreprocessor",
    "macro": "JBImportedMacro",
    "enum": "JBImportedEnum",
    "label": "JBImportedLabel",
    "constant": "JBImportedConstant",
    "string": "JBImportedString",
    "number": "JBImportedNumber",
    "comment": "JBImportedComment",
    "doc_comment": "JBImportedDocComment",
    "doc_tag": "JBImportedDocTag",
    "operator": "JBImportedOperator",
}


CORE_LINKS = {
    "Comment": "comment",
    "Constant": "constant",
    "Identifier": "identifier",
    "Statement": "keyword",
    "PreProc": "preprocessor",
    "Type": "type",
    "Special": "keyword",
    "String": "string",
    "Character": "string",
    "Number": "number",
    "Boolean": "keyword",
    "Float": "number",
    "Function": "function",
    "Keyword": "keyword",
    "Conditional": "keyword",
    "Repeat": "keyword",
    "Label": "label",
    "Include": "preprocessor",
    "Define": "macro",
    "Macro": "macro",
    "SpecialChar": "string",
    "Operator": "operator",
    "Exception": "keyword",
    "PreCondit": "preprocessor",
    "StorageClass": "keyword",
    "Structure": "keyword",
    "Typedef": "type",
    "Tag": "keyword",
    "Delimiter": "operator",
    "SpecialComment": "doc_comment",
    "Debug": "keyword",
}


CPP_LINKS = {
    "cIdentifier": "identifier",
    "cType": "type",
    "cTypeName": "type",
    "cStorageClass": "keyword",
    "cStructure": "keyword",
    "cTypedef": "type",
    "cInclude": "preprocessor",
    "cIncluded": "string",
    "cPreProc": "preprocessor",
    "cPreCondit": "preprocessor",
    "cUserFunction": "function",
    "cStructMember": "field",
    "cConstant": "constant",
    "cNumber": "number",
    "cFloat": "number",
    "cString": "string",
    "cCharacter": "string",
    "cSpecialCharacter": "string",
    "cBoolean": "keyword",
    "cppType": "type",
    "cppStorageClass": "keyword",
    "cppStructure": "keyword",
    "cppModifier": "keyword",
    "cppAccess": "keyword",
    "cppStatement": "keyword",
    "cppExceptions": "keyword",
    "cppBoolean": "keyword",
    "cppConstant": "constant",
    "cppNumber": "number",
    "cppFloat": "number",
    "cppString": "string",
    "cppRawString": "string",
    "cppCharacter": "string",
    "cppSTLnamespace": "namespace",
    "cppSTLvariable": "static_field",
    "cppSTLios": "method",
    "cppSTLfunction": "function",
    "cppSTLtype": "type",
    "cppSTLtypedef": "type",
    "cppSTLenum": "type",
    "cppSTLconstant": "constant",
    "cppSTLbool": "keyword",
    "cppSTLdefine": "macro",
    "cppSTLiterator": "type",
    "cppSTLexception": "type",
    "cppSTLconcept": "type",
    "cppAttribute": "macro",
    "cppAttributeBrackets": "identifier",
    "cppBuiltinType": "type",
    "cppTemplateKeyword": "keyword",
}


def normalize_color(value: str | None) -> str | None:
    if not value:
        return None
    candidate = value.strip().lstrip("#")
    if not re.fullmatch(r"[0-9a-fA-F]{3,8}", candidate):
        return None
    if len(candidate) == 3:
        candidate = "".join(character * 2 for character in candidate)
    elif len(candidate) == 8:
        candidate = candidate[:6]
    elif len(candidate) != 6:
        return None
    return f"#{candidate.lower()}"


def parse_scheme(path: Path) -> Scheme:
    try:
        root = ET.parse(path).getroot()
    except (OSError, ET.ParseError) as error:
        raise ConversionError(f"cannot parse {path}: {error}") from error

    if root.tag != "scheme":
        raise ConversionError(f"{path} is not a JetBrains .icls scheme")

    metadata: dict[str, str] = {}
    for property_node in root.findall("./metaInfo/property"):
        name = property_node.get("name")
        value = property_node.get("value")
        if name and value is not None:
            metadata[name] = value

    colors: dict[str, str] = {}
    for option in root.findall("./colors/option"):
        name = option.get("name")
        color = normalize_color(option.get("value"))
        if name and color:
            colors[name] = color

    raw_attributes: dict[str, RawAttribute] = {}
    for option in root.findall("./attributes/option"):
        name = option.get("name")
        if not name:
            continue
        base = option.get("baseAttributes")
        values: dict[str, str] = {}
        for value_option in option.findall("./value/option"):
            value_name = value_option.get("name")
            value = value_option.get("value")
            if not value_name or value is None:
                continue
            if value_name in {"FOREGROUND", "BACKGROUND", "EFFECT_COLOR"}:
                color = normalize_color(value)
                if color:
                    values[value_name.lower()] = color
            else:
                values[value_name.lower()] = value
        raw_attributes[name] = RawAttribute(base=base or None, values=values)

    scheme = Scheme(
        name=root.get("name") or path.stem,
        version=root.get("version"),
        parent=root.get("parent_scheme"),
        metadata=metadata,
        colors=colors,
        raw_attributes=raw_attributes,
    )
    resolve_attributes(scheme)
    return scheme


def resolve_attributes(scheme: Scheme) -> None:
    resolving: set[str] = set()

    def resolve(name: str) -> dict[str, str]:
        if name in scheme.attributes:
            return scheme.attributes[name]
        raw = scheme.raw_attributes.get(name)
        if raw is None:
            return {}
        if name in resolving:
            scheme.unresolved.append(
                {"attribute": name, "reason": "cyclic baseAttributes"}
            )
            return dict(raw.values)

        resolving.add(name)
        inherited = resolve(raw.base) if raw.base else {}
        result = dict(inherited)
        result.update(raw.values)
        resolving.remove(name)
        scheme.attributes[name] = result
        return result

    for attribute_name in scheme.raw_attributes:
        resolve(attribute_name)

    for name, raw in scheme.raw_attributes.items():
        if raw.base and raw.base not in scheme.raw_attributes:
            scheme.unresolved.append(
                {
                    "attribute": name,
                    "reason": f"missing baseAttributes target: {raw.base}",
                }
            )


def merge_role(scheme: Scheme, sources: Iterable[str]) -> Role:
    source_list = list(sources)
    merged: dict[str, str] = {}
    inherited_from: list[str] = []
    for source in source_list:
        attribute = scheme.attributes.get(source, {})
        if attribute:
            inherited_from.append(source)
        for key, value in attribute.items():
            merged.setdefault(key, value)
    if not merged:
        raise ConversionError(
            "input scheme does not provide a usable value for any of: "
            + ", ".join(source_list)
        )
    return Role(
        sources=source_list,
        attribute=merged,
        inherited_from=inherited_from,
    )


def resolve_roles(scheme: Scheme) -> tuple[dict[str, Role], dict[str, Role], dict[str, str]]:
    syntax_roles = {
        role_name: merge_role(scheme, sources)
        for role_name, sources in ROLE_SOURCES.items()
    }
    attribute_roles: dict[str, Role] = {}
    for role_name, sources in ATTRIBUTE_ROLES.items():
        try:
            attribute_roles[role_name] = merge_role(scheme, sources)
        except ConversionError:
            continue

    ui_colors: dict[str, str] = {}
    for role_name, sources in COLOR_ROLES.items():
        for source in sources:
            if source in scheme.colors:
                ui_colors[role_name] = scheme.colors[source]
                break
    return syntax_roles, attribute_roles, ui_colors


def color_luminance(color: str) -> float:
    red, green, blue = (
        int(color[index : index + 2], 16) / 255.0 for index in (1, 3, 5)
    )

    def linearize(channel: float) -> float:
        return (
            channel / 12.92
            if channel <= 0.04045
            else ((channel + 0.055) / 1.055) ** 2.4
        )

    return 0.2126 * linearize(red) + 0.7152 * linearize(green) + 0.0722 * linearize(blue)


def blend_colors(first: str, second: str, second_weight: float) -> str:
    first_weight = 1.0 - second_weight
    values = []
    for index in (1, 3, 5):
        component = round(
            int(first[index : index + 2], 16) * first_weight
            + int(second[index : index + 2], 16) * second_weight
        )
        values.append(f"{min(255, max(0, component)):02x}")
    return "#" + "".join(values)


def xterm_palette() -> list[tuple[int, int, int]]:
    palette: list[tuple[int, int, int]] = []
    steps = [0, 95, 135, 175, 215, 255]
    for red in steps:
        for green in steps:
            for blue in steps:
                palette.append((red, green, blue))
    for index in range(24):
        value = 8 + index * 10
        palette.append((value, value, value))
    return palette


XTERM_PALETTE = xterm_palette()


def nearest_xterm(color: str) -> int:
    rgb = tuple(int(color[index : index + 2], 16) for index in (1, 3, 5))
    best_index = 16
    best_distance = float("inf")
    for palette_index, candidate in enumerate(XTERM_PALETTE, start=16):
        distance = sum(
            (component - palette_component) ** 2
            for component, palette_component in zip(rgb, candidate)
        )
        if distance < best_distance:
            best_index = palette_index
            best_distance = distance
    return best_index


def style_flags(attribute: dict[str, str]) -> str:
    flags: list[str] = []
    font_type = attribute.get("font_type", "0")
    if font_type.isdigit():
        font_style = int(font_type)
        if font_style & 1:
            flags.append("bold")
        if font_style & 2:
            flags.append("italic")
    effect_type = attribute.get("effect_type", "0")
    if effect_type.isdigit():
        effect_style = int(effect_type)
        if effect_style in {1, 3, 5}:
            flags.append("underline")
        elif effect_style == 2:
            flags.append("undercurl")
        elif effect_style == 4:
            flags.append("strikethrough")
    return ",".join(flags) if flags else "NONE"


def highlight_line(group: str, attribute: dict[str, str]) -> str:
    foreground = attribute.get("foreground", "NONE")
    background = attribute.get("background", "NONE")
    effect_color = attribute.get("effect_color", "NONE")
    style = style_flags(attribute)
    cterm_foreground = str(nearest_xterm(foreground)) if foreground != "NONE" else "NONE"
    cterm_background = str(nearest_xterm(background)) if background != "NONE" else "NONE"
    parts = [
        f"highlight {group}",
        f"guifg={foreground}",
        f"guibg={background}",
        f"guisp={effect_color}",
        f"gui={style}",
        f"ctermfg={cterm_foreground}",
        f"ctermbg={cterm_background}",
        f"cterm={style}",
    ]
    return " ".join(parts)


def make_vim_name(value: str) -> str:
    name = re.sub(r"[^a-z0-9-]+", "-", value.lower()).strip("-")
    return name or "jb-imported"


def build_theme(
    scheme: Scheme, name: str
) -> tuple[str, dict[str, object]]:
    syntax_roles, attribute_roles, ui_colors = resolve_roles(scheme)
    normal = syntax_roles["identifier"]
    editor_foreground = normal.attribute.get("foreground")
    editor_background = normal.attribute.get("background")
    if not editor_foreground or not editor_background:
        raise ConversionError("TEXT/DEFAULT_IDENTIFIER must define foreground and background")

    for role in syntax_roles.values():
        if role.attribute.get("background") == editor_background:
            role.attribute.pop("background")

    background_kind = (
        "light" if color_luminance(editor_background) >= 0.5 else "dark"
    )

    selection_background = ui_colors.get("selection_background")
    selection_source = "SELECTION_BACKGROUND"
    if not selection_background:
        accent_role = attribute_roles.get("hyperlink") or syntax_roles["keyword"]
        accent = accent_role.attribute.get("foreground", editor_foreground)
        selection_background = blend_colors(editor_background, accent, 0.28)
        selection_source = "derived from editor background and accent color"

    lines = [
        '" Generated by jb-convert from a JetBrains editor color scheme.',
        '" Edit the converter and semantic profile, not this generated file.',
        "",
        "highlight clear",
        'if exists("syntax_on")',
        "  syntax reset",
        "endif",
        f"let g:colors_name = '{name}'",
        f"let g:jb_imported_scheme = '{name}'",
        f"set background={background_kind}",
        "",
    ]

    normal_attribute = dict(normal.attribute)
    normal_attribute["foreground"] = editor_foreground
    normal_attribute["background"] = editor_background
    lines.append(highlight_line("JBImportedNormal", normal_attribute))

    for role_name, role in syntax_roles.items():
        if role_name not in VIM_ROLE_NAMES:
            continue
        lines.append(highlight_line(VIM_ROLE_NAMES[role_name], role.attribute))

    extra_roles = {
        "Error": attribute_roles.get("error"),
        "Warning": attribute_roles.get("warning"),
        "Todo": attribute_roles.get("todo"),
        "Hyperlink": attribute_roles.get("hyperlink"),
        "Folded": attribute_roles.get("folded"),
        "MatchedBrace": attribute_roles.get("matched_brace"),
        "Search": attribute_roles.get("search"),
        "SearchCurrent": attribute_roles.get("search_current"),
    }
    for group_name, role in extra_roles.items():
        if role:
            lines.append(highlight_line(f"JBImported{group_name}", role.attribute))

    direct_ui_highlights = {
        "JBImportedCaretRow": {"background": ui_colors.get("caret_row", "NONE")},
        "JBImportedLineNumber": {
            "foreground": ui_colors.get("line_number", "NONE")
        },
        "JBImportedLineNumberCurrent": {
            "foreground": ui_colors.get("line_number_current", "NONE")
        },
        "JBImportedWhitespace": {"foreground": ui_colors.get("whitespace", "NONE")},
        "JBImportedIndentGuide": {
            "foreground": ui_colors.get("indent_guide", "NONE")
        },
        "JBImportedRightMargin": {
            "background": ui_colors.get("right_margin", "NONE")
        },
        "JBImportedCursor": {
            "foreground": editor_background,
            "background": ui_colors.get("caret", editor_foreground),
        },
        "JBImportedVisual": {
            "foreground": ui_colors.get("selection_foreground", "NONE"),
            "background": selection_background,
        },
    }
    for group_name, attribute in direct_ui_highlights.items():
        lines.append(highlight_line(group_name, attribute))

    if "popup_background" in ui_colors:
        lines.append(
            highlight_line(
                "JBImportedPopup",
                {
                    "foreground": editor_foreground,
                    "background": ui_colors["popup_background"],
                },
            )
        )

    lines.extend(
        [
            "",
            '" Generic Vim syntax links',
            "highlight! link Normal JBImportedNormal",
        ]
    )
    for group, role_name in CORE_LINKS.items():
        lines.append(f"highlight! link {group} {VIM_ROLE_NAMES[role_name]}")

    lines.extend(
        [
            "highlight! link Todo JBImportedTodo",
            "highlight! link Error JBImportedError",
            "highlight! link Title JBImportedConstant",
            "highlight! link Directory JBImportedString",
            "highlight! link MoreMsg JBImportedFunction",
            "highlight! link ModeMsg JBImportedIdentifier",
            "highlight! link WarningMsg JBImportedWarning",
            "highlight! link ErrorMsg JBImportedError",
            "highlight! link Search JBImportedSearch",
            "highlight! link IncSearch JBImportedSearchCurrent",
            "highlight! link CurSearch JBImportedSearchCurrent",
            "highlight! link MatchParen JBImportedMatchedBrace",
            "highlight! link Folded JBImportedFolded",
            "highlight! link CursorLine JBImportedCaretRow",
            "highlight! link CursorColumn JBImportedCaretRow",
            "highlight! link LineNr JBImportedLineNumber",
            "highlight! link CursorLineNr JBImportedLineNumberCurrent",
            "highlight! link NormalFloat JBImportedPopup",
            "highlight! link Pmenu JBImportedPopup",
            "highlight! link PmenuSel JBImportedVisual",
            "highlight! link SpecialKey JBImportedWhitespace",
            "highlight! link Whitespace JBImportedWhitespace",
            "highlight! link WhiteSpace JBImportedWhitespace",
            "highlight! link ColorColumn JBImportedRightMargin",
            "highlight! link Cursor JBImportedCursor",
            "highlight! link Visual JBImportedVisual",
            "highlight! link VisualNOS JBImportedVisual",
            "highlight! link Underlined JBImportedHyperlink",
            "",
            '" C and C++ syntax groups',
        ]
    )
    for group, role_name in CPP_LINKS.items():
        lines.append(f"highlight! link {group} {VIM_ROLE_NAMES[role_name]}")

    lines.extend(
        [
            "",
            "if exists('*jb#ui#configure_terminal_background')",
            f"  call jb#ui#configure_terminal_background('{editor_background}')",
            "endif",
            "",
        ]
    )

    report: dict[str, object] = {
        "source": {
            "name": scheme.name,
            "version": scheme.version,
            "parent": scheme.parent,
            "metadata": scheme.metadata,
            "attribute_count": len(scheme.raw_attributes),
            "color_count": len(scheme.colors),
        },
        "output": {
            "name": name,
            "background": background_kind,
            "foreground": editor_foreground,
            "editor_background": editor_background,
            "selection_background": selection_background,
            "selection_source": selection_source,
        },
        "roles": {
            role_name: {
                "sources": role.sources,
                "inherited_from": role.inherited_from,
                **role.attribute,
            }
            for role_name, role in sorted(syntax_roles.items())
        },
        "attribute_roles": {
            role_name: {
                "sources": role.sources,
                "inherited_from": role.inherited_from,
                **role.attribute,
            }
            for role_name, role in sorted(attribute_roles.items())
        },
        "ui_colors": dict(sorted(ui_colors.items())),
        "unresolved": sorted(
            scheme.unresolved,
            key=lambda item: (item["attribute"], item["reason"]),
        ),
    }
    return "\n".join(lines), report


def convert_file(
    source: Path,
    output: Path,
    report_path: Path | None = None,
    name: str | None = None,
) -> dict[str, object]:
    scheme = parse_scheme(source)
    vim_name = make_vim_name(name or scheme.name)
    theme, report = build_theme(scheme, vim_name)

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(theme, encoding="utf-8")
    if report_path:
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(
            json.dumps(report, indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
    return report


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Convert a JetBrains .icls editor scheme to a Vim color scheme."
    )
    parser.add_argument("source", type=Path, help="JetBrains .icls input file")
    parser.add_argument(
        "-o",
        "--output",
        required=True,
        type=Path,
        help="Vim color scheme output file",
    )
    parser.add_argument(
        "--report",
        type=Path,
        help="optional JSON conversion report",
    )
    parser.add_argument(
        "--name",
        help="Vim colors_name (default: derived from the .icls name)",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        report = convert_file(
            source=args.source,
            output=args.output,
            report_path=args.report,
            name=args.name,
        )
    except ConversionError as error:
        print(f"jb-convert: {error}", file=sys.stderr)
        return 1

    output = report["output"]
    source = report["source"]
    unresolved = report["unresolved"]
    print(
        f"Converted {source['name']} ({source['attribute_count']} attributes) "
        f"to {args.output}"
    )
    print(
        f"theme={output['name']} background={output['background']} "
        f"fg={output['foreground']} bg={output['editor_background']}"
    )
    if unresolved:
        print(f"unresolved={len(unresolved)}; see the JSON report for details")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
