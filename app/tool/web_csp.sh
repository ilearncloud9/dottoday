#!/usr/bin/env bash
# Writes the web Content-Security-Policy and security headers for one
# deployment (docs/06 §8, docs/09 M5.7) into a built app:
#   tool/web_csp.sh <supabase-url> [build/web]
# - a <meta http-equiv> CSP in index.html (works on any static host), and
# - _headers (Netlify / Cloudflare Pages format) with the same CSP plus the
#   headers a meta tag can't carry (frame-ancestors, HSTS, framing, referrer).
# Run after `flutter build web`; CI's web job serves the result and runs the
# axe audit and the encrypted-DB probe under it.
set -euo pipefail
supabase="${1:?usage: web_csp.sh <supabase-url> [build-dir]}"
dir="${2:-build/web}"
supabase="${supabase%/}"
ws="${supabase/https:/wss:}"
ws="${ws/http:/ws:}"
# 'wasm-unsafe-eval': CanvasKit and the encrypted SQLite (sqlite3mc.wasm).
# style-src 'unsafe-inline': Flutter's engine sets inline styles on its DOM.
# fonts.gstatic.com: Flutter's glyph fallback (emoji, CJK in task titles);
# only font files are fetched, nothing about the user is sent.
csp="default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; font-src 'self' https://fonts.gstatic.com; connect-src 'self' ${supabase} ${ws} https://fonts.gstatic.com; worker-src 'self' blob:; manifest-src 'self'; object-src 'none'; base-uri 'self'; form-action 'none'"
python3 - "$dir/index.html" "$csp" <<'PY'
import sys
path, csp = sys.argv[1], sys.argv[2]
html = open(path).read()
tag = f'<meta http-equiv="Content-Security-Policy" content="{csp}">'
if 'http-equiv="Content-Security-Policy"' not in html:
    html = html.replace('<head>', '<head>\n  ' + tag, 1)
open(path, 'w').write(html)
PY
cat > "$dir/_headers" <<HEADERS
/*
  Content-Security-Policy: ${csp}; frame-ancestors 'none'
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: no-referrer
  Strict-Transport-Security: max-age=31536000; includeSubDomains
  Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=()
/sw.js
  Cache-Control: no-cache
  Service-Worker-Allowed: /
HEADERS
echo "CSP written to $dir/index.html and $dir/_headers"
