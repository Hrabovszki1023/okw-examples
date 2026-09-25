"""Check that every English Handbuch page is in sync with its German source.

German (``*.de.md``) is the leading language. Each English page (``*.md``)
carries the hash of the German source it was translated from::

    ---
    source_hash: 3f2a9c0d1e4b
    ---

Status per page pair:

- ``ok``       -- English page exists and ``source_hash`` matches
- ``missing``  -- no English page for a German page
- ``outdated`` -- German page changed since the English page was translated

Usage (run from ``okw-examples/``)::

    python scripts/check-translations.py            # report, always exit 0
    python scripts/check-translations.py --strict   # exit 1 on missing/outdated
    python scripts/check-translations.py --stamp docs/grundlagen/keywords.de.md
    python scripts/check-translations.py --stamp    # stamp all pairs

``--stamp`` writes the current German hash into the English page. Run it
only after the English page has been updated from the German source.
"""

import argparse
import hashlib
import re
import sys
from pathlib import Path

DOCS = Path(__file__).resolve().parent.parent / "docs"
FRONT_MATTER = re.compile(r"\A---\n(.*?)\n---\n", re.DOTALL)
HASH_LINE = re.compile(r"^source_hash:\s*(\S+)\s*$", re.MULTILINE)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8").replace("\r\n", "\n")


def source_hash(de_path: Path) -> str:
    return hashlib.sha256(read_text(de_path).encode("utf-8")).hexdigest()[:12]


def english_path(de_path: Path) -> Path:
    return de_path.with_name(de_path.name[: -len(".de.md")] + ".md")


def stored_hash(en_text: str):
    match = FRONT_MATTER.match(en_text)
    if not match:
        return None
    found = HASH_LINE.search(match.group(1))
    return found.group(1) if found else None


def stamp(de_path: Path) -> None:
    en_path = english_path(de_path)
    text = read_text(en_path)
    line = f"source_hash: {source_hash(de_path)}"
    match = FRONT_MATTER.match(text)
    if match:
        body = match.group(1)
        body = HASH_LINE.sub(line, body) if HASH_LINE.search(body) else body + "\n" + line
        text = f"---\n{body}\n---\n" + text[match.end():]
    else:
        text = f"---\n{line}\n---\n\n" + text
    en_path.write_text(text, encoding="utf-8", newline="\n")


def status(de_path: Path) -> str:
    en_path = english_path(de_path)
    if not en_path.exists():
        return "missing"
    return "ok" if stored_hash(read_text(en_path)) == source_hash(de_path) else "outdated"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--strict", action="store_true", help="exit 1 on missing/outdated pages")
    parser.add_argument("--stamp", nargs="*", metavar="DE_FILE", help="stamp English pages (all if no file given)")
    args = parser.parse_args()

    de_files = sorted(DOCS.rglob("*.de.md"))

    if args.stamp is not None:
        targets = [Path(f).resolve() for f in args.stamp] or de_files
        for de_path in targets:
            if not english_path(de_path).exists():
                print(f"skip (no English page): {de_path.relative_to(DOCS)}")
                continue
            stamp(de_path)
            print(f"stamped: {english_path(de_path).relative_to(DOCS)}")
        return 0

    problems = 0
    for de_path in de_files:
        state = status(de_path)
        if state != "ok":
            problems += 1
            print(f"{state:9} {english_path(de_path).relative_to(DOCS).as_posix()}")
    print(f"{len(de_files) - problems}/{len(de_files)} English pages in sync with German source")
    return 1 if (args.strict and problems) else 0


if __name__ == "__main__":
    sys.exit(main())
