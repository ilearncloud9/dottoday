# Universal links / App Links (deferred, docs/09 M5.0)

`dottoday://` works on every platform today. `https://<domain>/task/<id>`
links additionally need, once the owner has a domain and the paid Apple
account (see the store-readiness checklist):

1. Serve these two files, filled in, at `https://<domain>/.well-known/`
   (`apple-app-site-association` with no extension, `application/json`).
2. iOS/macOS: add `applinks:<domain>` to the Associated Domains entitlement
   (Personal Teams can't sign this capability).
3. Android: add an `autoVerify="true"` intent filter for `https://<domain>`
   next to the `dottoday` one in `AndroidManifest.xml`.

The router already accepts the same paths, so no Dart change is needed.
