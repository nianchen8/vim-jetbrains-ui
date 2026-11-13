from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
TOOLS_DIR = REPO_ROOT / "tools"
sys.path.insert(0, str(TOOLS_DIR))

import jb_convert  # noqa: E402


class ConverterTests(unittest.TestCase):
    fixture = REPO_ROOT / "test" / "fixtures" / "import_dark.icls"

    def test_resolves_base_attributes_and_reports_missing_targets(self) -> None:
        scheme = jb_convert.parse_scheme(self.fixture)

        self.assertEqual("Import Test", scheme.name)
        self.assertEqual("2026.3", scheme.metadata["ideVersion"])
        keyword = scheme.attributes["OC.KEYWORD"]
        self.assertEqual("#ffaa00", keyword["foreground"])
        self.assertEqual("1", keyword["font_type"])
        self.assertIn(
            {
                "attribute": "UNUSED_ATTRIBUTE",
                "reason": "missing baseAttributes target: DOES_NOT_EXIST",
            },
            scheme.unresolved,
        )

    def test_generates_vim_scheme_and_report(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            output = root / "import-test.vim"
            report_path = root / "report.json"
            report = jb_convert.convert_file(
                self.fixture,
                output,
                report_path=report_path,
                name="import-test",
            )
            theme = output.read_text(encoding="utf-8")
            persisted = json.loads(report_path.read_text(encoding="utf-8"))

            self.assertEqual(report, persisted)
            self.assertIn("let g:colors_name = 'import-test'", theme)
            self.assertIn("let g:jb_imported_scheme = 'import-test'", theme)
            self.assertIn("set background=dark", theme)
            self.assertIn(
                "highlight JBImportedKeyword guifg=#ffaa00 guibg=NONE "
                "guisp=NONE gui=bold",
                theme,
            )
            self.assertIn("highlight! link cppExceptions JBImportedKeyword", theme)
            self.assertIn("highlight! link cppSTLnamespace JBImportedNamespace", theme)
            self.assertIn("highlight! link cppSTLvariable JBImportedStaticField", theme)
            self.assertIn("highlight! link cppSTLtype JBImportedType", theme)
            self.assertEqual(
                "derived from editor background and accent color",
                report["output"]["selection_source"],
            )

    @unittest.skipUnless(shutil.which("vim"), "Vim is required")
    def test_generated_scheme_loads_in_vim(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            colors_dir = root / "colors"
            output = colors_dir / "import-test.vim"
            jb_convert.convert_file(
                self.fixture,
                output,
                name="import-test",
            )
            test_script = root / "inspect.vim"
            test_script.write_text(
                "\n".join(
                    [
                        f"set runtimepath^={root}",
                        "set termguicolors",
                        "colorscheme import-test",
                        "silent edit " + str(REPO_ROOT / "test/fixtures/sample.cpp"),
                        "silent! setlocal filetype=cpp",
                        "silent! setlocal syntax=cpp",
                        "let s:normal = synIDattr(synIDtrans(hlID('Normal')), 'bg#', 'gui')",
                        "let s:namespace = synIDattr(synIDtrans(hlID('cppSTLnamespace')), 'fg#', 'gui')",
                        "let s:field = synIDattr(synIDtrans(hlID('cppSTLvariable')), 'fg#', 'gui')",
                        "let s:keyword_style = synIDattr(synIDtrans(hlID('cppExceptions')), 'bold', 'gui')",
                        "let s:result = join([&background, s:normal, s:namespace, s:field, s:keyword_style], '|')",
                        "call writefile([s:result], '" + str(root / "result.txt") + "')",
                        "qa!",
                    ]
                ),
                encoding="utf-8",
            )
            subprocess.run(
                [
                    "vim",
                    "-Nu",
                    "NONE",
                    "-i",
                    "NONE",
                    "-n",
                    "-X",
                    "-es",
                    "-S",
                    str(test_script),
                ],
                check=True,
                cwd=root,
                capture_output=True,
                text=True,
            )
            result = (root / "result.txt").read_text(encoding="utf-8").strip()

        self.assertEqual("dark|#101010|#e0e0e0|#aa00aa|1", result)

    @unittest.skipUnless(
        os.environ.get("JB_CPP_RUNTIME") and shutil.which("vim"),
        "vim-cpp-modern and Vim are required",
    )
    def test_generated_scheme_uses_cpp_modern_after_load(self) -> None:
        runtime = Path(os.environ["JB_CPP_RUNTIME"]).resolve()
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            output = root / "colors" / "import-test.vim"
            jb_convert.convert_file(self.fixture, output, name="import-test")
            test_script = root / "inspect-cpp.vim"
            test_script.write_text(
                "\n".join(
                    [
                        f"execute 'set runtimepath^=' . fnameescape('{runtime}')",
                        f"execute 'set runtimepath+=' . fnameescape('{runtime}/after')",
                        f"set runtimepath^={root}",
                        "set termguicolors",
                        "syntax on",
                        "filetype plugin indent on",
                        "colorscheme import-test",
                        "enew",
                        "setlocal filetype=cpp",
                        "setlocal syntax=cpp",
                        "call setline(1, ["
                        "'#include <iostream>', "
                        "'int main() {', "
                        "'    std::cout << \"hello\" << std::endl;', "
                        "'    bool ok = true;', "
                        "'    return 0;', "
                        "'}'])",
                        "syntax sync fromstart",
                        "let s:tokens = [[1, 2], [2, 1], [2, 5], [3, 5], [3, 10], [4, 17], [5, 5]]",
                        "let s:rows = []",
                        "for s:token in s:tokens",
                        "  let s:id = synID(s:token[0], s:token[1], 1)",
                        "  call add(s:rows, join([synIDattr(s:id, 'name'), "
                        "synIDattr(synIDtrans(s:id), 'fg#', 'gui')], '|'))",
                        "endfor",
                        "call writefile(s:rows, '" + str(root / "cpp-result.txt") + "')",
                        "qa!",
                    ]
                ),
                encoding="utf-8",
            )
            subprocess.run(
                [
                    "vim",
                    "-Nu",
                    "NONE",
                    "-i",
                    "NONE",
                    "-n",
                    "-X",
                    "-es",
                    "-S",
                    str(test_script),
                ],
                check=True,
                cwd=root,
                capture_output=True,
                text=True,
            )
            rows = (root / "cpp-result.txt").read_text(encoding="utf-8").splitlines()

        self.assertEqual(
            [
                "cInclude|#ffaa00",
                "cType|#ffaa00",
                "cUserFunction|#0000ff",
                "cppSTLnamespace|#e0e0e0",
                "cppSTLvariable|#aa00aa",
                "cppBoolean|#ffaa00",
                "cStatement|#ffaa00",
            ],
            rows,
        )


if __name__ == "__main__":
    unittest.main()
