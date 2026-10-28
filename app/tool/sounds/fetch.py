"""Downloads the original sound files named in assets/sounds/manifest.json.

Run from app/:  python3 -I tool/sounds/fetch.py

docs/12-sounds.md §1, §5. The manifest is the only list of sources: this
script has no URLs of its own. For an entry without `fileUrl` it reads the
entry's `sourceUrl` page once, takes the sound from the page's schema.org
AudioObject (the page also links other sounds), checks that the title and
licence are the ones the manifest records, and writes the `.ogg` link back
as `fileUrl`. Then it downloads every file to tool/sounds/originals/
(gitignored, never shipped). Already-downloaded files are left alone.
"""

from __future__ import annotations

import argparse
import html
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

APP = Path(__file__).resolve().parents[2]
MANIFEST = APP / "assets" / "sounds" / "manifest.json"
ORIGINALS = APP / "tool" / "sounds" / "originals"

# A page may only point at its own site's sound storage.
ALLOWED_HOST = "notificationsounds.com"
STORAGE_PREFIX = "/storage/sounds/"
LICENSE_URLS = {
    "CC-BY-4.0": "https://creativecommons.org/licenses/by/4.0/",
    "CC0-1.0": "https://creativecommons.org/publicdomain/zero/1.0/",
}
MAX_BYTES = 5 * 1024 * 1024
USER_AGENT = "dottoday-sound-fetch/1 (+https://github.com/ilearncloud9)"

_LD_JSON = re.compile(
    r'<script[^>]*type="application/ld\+json"[^>]*>(.*?)</script>', re.S
)


class FetchError(Exception):
    """A page or file that doesn't match what the manifest records."""


def _get(url: str, *, limit: int = MAX_BYTES) -> bytes:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                data = response.read(limit + 1)
        except OSError as e:
            if attempt == 2:
                raise FetchError(f"{url}: {e}") from e
            time.sleep(2**attempt)
            continue
        if len(data) > limit:
            raise FetchError(f"{url}: larger than {limit} bytes")
        return data
    raise AssertionError("unreachable")


def _audio_objects(page: str) -> list[dict]:
    found = []
    for block in _LD_JSON.findall(page):
        try:
            data = json.loads(html.unescape(block))
        except json.JSONDecodeError:
            continue
        stack = [data]
        while stack:
            item = stack.pop()
            if isinstance(item, list):
                stack.extend(item)
            elif isinstance(item, dict):
                if item.get("@type") == "AudioObject":
                    found.append(item)
                stack.extend(item.values())
    return found


def _checked_storage_url(url: str) -> str:
    parts = urllib.parse.urlsplit(url)
    if parts.scheme != "https" or parts.hostname != ALLOWED_HOST:
        raise FetchError(f"{url}: not on https://{ALLOWED_HOST}")
    if not parts.path.startswith(STORAGE_PREFIX) or ".." in parts.path:
        raise FetchError(f"{url}: not under {STORAGE_PREFIX}")
    return url


def resolve_file_url(entry: dict) -> str:
    """The `.ogg` behind [entry]'s page, after checking title and licence."""
    page = _get(entry["sourceUrl"]).decode("utf-8", "replace")
    audio = _audio_objects(page)
    if len(audio) != 1:
        raise FetchError(f"{entry['id']}: {len(audio)} AudioObjects on the page")
    sound = audio[0]
    if sound.get("name") != entry["sourceTitle"]:
        raise FetchError(
            f"{entry['id']}: page title {sound.get('name')!r}, "
            f"manifest says {entry['sourceTitle']!r}"
        )
    expected = LICENSE_URLS[entry["license"]]
    if sound.get("license") != expected:
        raise FetchError(f"{entry['id']}: page licence {sound.get('license')!r}")
    content = _checked_storage_url(sound["contentUrl"])
    ogg = re.sub(r"\.[a-z0-9]+$", ".ogg", content)
    # Prefer the .ogg the page offers beside the .mp3; else keep the .mp3.
    path = urllib.parse.urlsplit(ogg).path
    return ogg if path in page else content


def _with_file_url(entry: dict, file_url: str) -> dict:
    """[entry] with `fileUrl` placed right after `sourceUrl`."""
    out = {}
    for key, value in entry.items():
        if key == "fileUrl":
            continue
        out[key] = value
        if key == "sourceUrl":
            out["fileUrl"] = file_url
    return out


def write_manifest(manifest: dict, path: Path = MANIFEST) -> None:
    text = json.dumps(manifest, indent=2, ensure_ascii=False) + "\n"
    path.write_text(text, encoding="utf-8")


def original_path(entry: dict) -> Path:
    suffix = Path(urllib.parse.urlsplit(entry["fileUrl"]).path).suffix
    return ORIGINALS / f"{entry['file']}{suffix}"


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--only", nargs="*", help="sound ids to fetch")
    parser.add_argument(
        "--refresh", action="store_true", help="re-read pages for fileUrl"
    )
    args = parser.parse_args(argv)

    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    ORIGINALS.mkdir(parents=True, exist_ok=True)
    failures = []
    for i, entry in enumerate(manifest["sounds"]):
        if "sourceUrl" not in entry:
            continue  # first-party: made in this repo (tool/gen_sounds.dart)
        if args.only and entry["id"] not in args.only:
            continue
        try:
            if args.refresh or "fileUrl" not in entry:
                entry = _with_file_url(entry, resolve_file_url(entry))
                manifest["sounds"][i] = entry
                write_manifest(manifest)
            target = original_path(entry)
            if target.exists():
                continue
            data = _get(_checked_storage_url(entry["fileUrl"]))
            target.write_bytes(data)
            print(f"{entry['id']}: {len(data)} bytes")
        except FetchError as e:
            failures.append(str(e))
            print(f"FAILED {e}", file=sys.stderr)
    if failures:
        print(f"{len(failures)} failed", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
