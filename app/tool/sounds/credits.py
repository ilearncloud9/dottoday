"""Writes the repo's CREDITS.md from assets/sounds/manifest.json.

Run from app/:  python3 -I tool/sounds/credits.py

docs/12-sounds.md §1: one section per credited source (its licence notice,
then one row per sound with its source page), and the first-party tones.
test/policy/sounds_manifest_test.dart fails when this file is stale.
"""

from __future__ import annotations

import json
from pathlib import Path

APP = Path(__file__).resolve().parents[2]
MANIFEST = APP / "assets" / "sounds" / "manifest.json"
CREDITS = APP.parent / "CREDITS.md"


def credits_markdown(manifest: dict) -> str:
    """CREDITS.md: one section per credited source, one row per sound."""
    lines = [
        "# Credits",
        "",
        "Generated from `app/assets/sounds/manifest.json` by",
        "`app/tool/sounds/build.py`. Do not edit by hand.",
        "",
    ]
    for key, source in manifest["sources"].items():
        if not source.get("credit"):
            continue
        lines += [f"## {source['name']}", "", source["notice"], ""]
        lines += ["| Dottoday id | Dottoday name | Original | Source page | Also |",
                  "|---|---|---|---|---|"]
        for s in manifest["sounds"]:
            if s["source"] == key:
                also = s["modified"] if isinstance(s["modified"], str) else ""
                lines.append(f"| `{s['id']}` | {s['name']} | {s['sourceTitle']}"
                             f" | <{s['sourceUrl']}> | {also} |")
        lines.append("")
    first_party = [s["name"] for s in manifest["sounds"]
                   if not manifest["sources"][s["source"]].get("credit")]
    lines += ["## Made for Dottoday", "",
              "Synthesised by `app/tool/gen_sounds.dart`; no third-party audio: "
              + ", ".join(first_party) + ".", ""]
    return "\n".join(lines)


if __name__ == "__main__":
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    CREDITS.write_text(credits_markdown(manifest), encoding="utf-8")
