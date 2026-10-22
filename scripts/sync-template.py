"""Write template.js and tests.yaml back into template.tpl."""

from pathlib import Path


def replace_section(tpl: str, name: str, nxt: str, body: str) -> str:
    marker = f"___{name}___\n"
    start = tpl.index(marker) + len(marker)
    end = tpl.index(f"___{nxt}___", start)
    middle = "\n" + body.strip("\n") + "\n\n\n"
    return tpl[:start] + middle + tpl[end:]


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    tpl_path = root / "template.tpl"
    raw = tpl_path.read_bytes()
    bom = raw.startswith(b"\xef\xbb\xbf")
    tpl = raw.decode("utf-8-sig")
    tpl = replace_section(
        tpl,
        "SANDBOXED_JS_FOR_WEB_TEMPLATE",
        "WEB_PERMISSIONS",
        (root / "template.js").read_text(encoding="utf-8"),
    )
    tpl = replace_section(
        tpl,
        "TESTS",
        "NOTES",
        (root / "tests.yaml").read_text(encoding="utf-8"),
    )
    out = ("\ufeff" if bom else "") + tpl
    tpl_path.write_text(out, encoding="utf-8")
    print("template.tpl updated from template.js and tests.yaml")


if __name__ == "__main__":
    main()
