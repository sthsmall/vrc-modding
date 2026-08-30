#!/usr/bin/env python3
"""Search installed Modular Avatar source/docs for an exact or partial symbol."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("package_source")
    parser.add_argument("symbol")
    args = parser.parse_args()

    root = Path(args.package_source).expanduser().resolve()
    if not root.is_dir():
        raise SystemExit(f"Package source directory not found: {root}")

    pattern = re.compile(re.escape(args.symbol), re.I)
    extensions = {".cs", ".md", ".json", ".uxml", ".uss"}
    count = 0
    for path in root.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in extensions:
            continue
        try:
            lines = path.read_text(encoding="utf-8-sig", errors="replace").splitlines()
        except OSError:
            continue
        for number, line in enumerate(lines, 1):
            if pattern.search(line):
                print(f"{path}:{number}: {line.strip()}")
                count += 1
    return 0 if count else 1


if __name__ == "__main__":
    raise SystemExit(main())
