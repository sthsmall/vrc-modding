#!/usr/bin/env python3
"""Inspect a Unity project for Modular Avatar/NDMF package resolution.

This script only reads local files. It does not connect to Unity or MCP.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


def load_json(path: Path) -> dict[str, Any] | None:
    if not path.is_file():
        return None
    with path.open("r", encoding="utf-8-sig") as f:
        return json.load(f)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("project_root", nargs="?", default=".")
    args = parser.parse_args()

    root = Path(args.project_root).expanduser().resolve()
    required = [root / "Assets", root / "Packages", root / "ProjectSettings"]
    if not all(p.exists() for p in required):
        raise SystemExit(f"Not a Unity project root: {root}")

    manifest_path = root / "Packages" / "manifest.json"
    lock_path = root / "Packages" / "packages-lock.json"
    manifest = load_json(manifest_path) or {}
    lock = load_json(lock_path) or {}

    unity_version = None
    pv = root / "ProjectSettings" / "ProjectVersion.txt"
    if pv.is_file():
        first = pv.read_text(encoding="utf-8-sig").splitlines()[0]
        match = re.match(r"m_EditorVersion:\s*(.+)", first)
        if match:
            unity_version = match.group(1).strip()

    candidates: dict[str, dict[str, Any]] = {}
    for package_id, spec in manifest.get("dependencies", {}).items():
        if re.search(r"modular.?avatar", package_id, re.I):
            candidates[package_id] = {"packageId": package_id, "manifestSpec": spec}

    for package_id, value in lock.get("dependencies", {}).items():
        if re.search(r"modular.?avatar", package_id, re.I):
            item = candidates.setdefault(package_id, {"packageId": package_id})
            item.update({
                "resolvedVersion": value.get("version"),
                "source": value.get("source"),
                "depth": value.get("depth"),
            })

    cache = root / "Library" / "PackageCache"
    for package_id, item in candidates.items():
        locations: list[Path] = []
        embedded = root / "Packages" / package_id
        if embedded.is_dir():
            locations.append(embedded.resolve())
        if cache.is_dir():
            locations.extend(p.resolve() for p in cache.glob(f"{package_id}@*") if p.is_dir())
        locations = list(dict.fromkeys(locations))
        item["locations"] = [str(p) for p in locations]
        package_json = []
        for location in locations:
            pj = location / "package.json"
            try:
                data = load_json(pj)
                if data:
                    package_json.append({
                        "path": str(pj),
                        "name": data.get("name"),
                        "displayName": data.get("displayName"),
                        "version": data.get("version"),
                        "unity": data.get("unity"),
                    })
            except Exception as exc:  # report malformed local package metadata
                package_json.append({"path": str(pj), "error": str(exc)})
        item["packageJson"] = package_json

    ndmf = []
    for package_id, value in lock.get("dependencies", {}).items():
        if re.search(r"ndmf", package_id, re.I):
            ndmf.append({
                "packageId": package_id,
                "version": value.get("version"),
                "source": value.get("source"),
            })

    result = {
        "projectRoot": str(root),
        "unityVersion": unity_version,
        "manifestPath": str(manifest_path),
        "lockPath": str(lock_path),
        "modularAvatar": list(candidates.values()),
        "ndmf": ndmf,
        "notes": [
            "Do not modify Library/PackageCache.",
            "Resolve exact component fields from the located installed source.",
            "If no package is found, confirm the package ID in manifest/lock files.",
        ],
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
