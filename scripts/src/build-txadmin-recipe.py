#!/usr/bin/env python3
"""Generate a self-contained txAdmin recipe from the framework Lua resources."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "txadmin" / "recipe.yaml"
SERVER_CFG = ROOT / "txadmin" / "server.cfg"
RESOURCE_ROOT = ROOT / "resources" / "[framework]"


def yaml_block(path: str, content: str) -> str:
    lines = [
        "  - action: write_file",
        f"    file: ./{path}",
        "    data: |",
    ]
    content = content.rstrip("\n")
    lines.extend("      " + line if line else "      " for line in content.splitlines())
    if not content:
        lines.append("      ")
    return "\n".join(lines)


def main() -> None:
    resource_files = sorted(
        path for path in RESOURCE_ROOT.rglob("*")
        if path.is_file() and path.name != ".gitkeep"
    )
    files = [(path.relative_to(ROOT).as_posix(), path.read_text(encoding="utf-8")) for path in resource_files]
    files.append(("server.cfg", SERVER_CFG.read_text(encoding="utf-8")))

    header = """$engine: 3
$onesync: on
name: Civic Framework
version: 0.1.0
author: Civic Framework
description: A standalone Lua roleplay foundation with player data, inventory, vehicles, and housing.

tasks:
  - action: download_github
    src: https://github.com/citizenfx/cfx-server-data
    ref: master
    subpath: resources
    dest: ./resources/[cfx-default]

"""
    tasks = "\n\n".join(yaml_block(path, content) for path, content in files)
    footer = """
  - action: replace_string
    mode: all_vars
    file: ./server.cfg

  - action: ensure_dir
    path: ./resources/[framework]/civic_core/data
"""
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(header + tasks + "\n" + footer, encoding="utf-8")
    print(f"Generated {OUTPUT.relative_to(ROOT)} with {len(files)} embedded files.")


if __name__ == "__main__":
    main()
