#!/usr/bin/env bash
# Puts the Drift web database runtime next to the web build inputs (M2.1, ADR-0003):
#   app/web/drift_worker.js  copied from the locked drift package (always version-matched)
#   app/web/sqlite3.wasm     downloaded from the sqlite3.dart release matching the locked
#                            sqlite3 version, verified against a pinned SHA-256
# Both are gitignored. Run after `flutter pub get`, before `flutter build web`.
# Bumping sqlite3 in pubspec.lock fails here until its wasm digest is pinned below
# (digest: `gh api repos/simolus3/sqlite3.dart/releases` → asset `digest`).
set -euo pipefail
cd "$(dirname "$0")/../app"

wasm_sha256() {
  case "$1" in
    3.7.1) echo 87c1869b533ea4b6daa1f4dc6aa7e9cf3dae6e6ea53f8ed57080c08eb5f64303 ;;
    *) echo "" ;;
  esac
}

locked_version() {
  awk -v pkg="$1" '$1 == pkg":" {found=1} found && $1 == "version:" {gsub(/"/, "", $2); print $2; exit}' pubspec.lock
}

package_root() {
  python3 -c 'import json,sys
cfg = json.load(open(".dart_tool/package_config.json"))
uri = next(p["rootUri"] for p in cfg["packages"] if p["name"] == sys.argv[1])
print(uri.removeprefix("file://"))' "$1"
}

cp "$(package_root drift)/drift_worker.js" web/drift_worker.js

version="$(locked_version sqlite3)"
sha="$(wasm_sha256 "$version")"
if [[ -z "$sha" ]]; then
  echo "::error::No pinned sqlite3.wasm digest for sqlite3 $version; add it to tool/web_db_assets.sh" >&2
  exit 1
fi
url="https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-$version/sqlite3.wasm"
curl -fsSL --retry 3 -o web/sqlite3.wasm.tmp "$url"
echo "$sha  web/sqlite3.wasm.tmp" | shasum -a 256 -c - >/dev/null
mv web/sqlite3.wasm.tmp web/sqlite3.wasm
echo "web DB assets: drift_worker.js, sqlite3.wasm ($version)"
