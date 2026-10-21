#!/usr/bin/env bash
# Puts the encrypted Drift web database runtime next to the web build inputs (M2.1, M2.9,
# ADR-0003):
#   app/web/sqlite3mc.wasm   SQLite3MultipleCiphers from the sqlite3.dart release matching the
#                            locked sqlite3 version, verified against a pinned SHA-256
# It is gitignored. Run after `flutter pub get`, before `flutter build web`.
# Bumping sqlite3 in pubspec.lock fails here until its sqlite3mc.wasm digest is pinned below
# (digest: `gh api repos/simolus3/sqlite3.dart/releases` → asset `digest`).
set -euo pipefail
cd "$(dirname "$0")/../app"

wasm_sha256() {
  case "$1" in
    3.7.1) echo df6a960b705431ba34cb29080040ef0a8ed56ced0457e25ce38bf1d63152d360 ;;
    *) echo "" ;;
  esac
}

locked_version() {
  awk -v pkg="$1" '$1 == pkg":" {found=1} found && $1 == "version:" {gsub(/"/, "", $2); print $2; exit}' pubspec.lock
}

version="$(locked_version sqlite3)"
sha="$(wasm_sha256 "$version")"
if [[ -z "$sha" ]]; then
  echo "::error::No pinned sqlite3mc.wasm digest for sqlite3 $version; add it to tool/web_db_assets.sh" >&2
  exit 1
fi
url="https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-$version/sqlite3mc.wasm"
curl -fsSL --retry 3 -o web/sqlite3mc.wasm.tmp "$url"
echo "$sha  web/sqlite3mc.wasm.tmp" | shasum -a 256 -c - >/dev/null
mv web/sqlite3mc.wasm.tmp web/sqlite3mc.wasm
echo "web DB assets: sqlite3mc.wasm ($version)"
