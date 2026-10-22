"""Fail when template.js or tests.yaml drift from template.tpl."""

from pathlib import Path


def section(tpl: str, name: str, nxt: str) -> str:
    marker = f"___{name}___\n"
    start = tpl.index(marker) + len(marker)
    end = tpl.index(f"___{nxt}___", start)
    return tpl[start:end].strip("\n") + "\n"


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    tpl = (root / "template.tpl").read_text(encoding="utf-8-sig")
    expected_js = section(tpl, "SANDBOXED_JS_FOR_WEB_TEMPLATE", "WEB_PERMISSIONS")
    expected_tests = section(tpl, "TESTS", "NOTES")
    js = (root / "template.js").read_text(encoding="utf-8")
    tests = (root / "tests.yaml").read_text(encoding="utf-8")
    failed = False
    if js != expected_js:
        print("template.js does not match ___SANDBOXED_JS_FOR_WEB_TEMPLATE___")
        failed = True
    if tests != expected_tests:
        print("tests.yaml does not match ___TESTS___")
        failed = True
    if failed:
        raise SystemExit(1)
    print("template.js and tests.yaml match template.tpl")


if __name__ == "__main__":
    main()
