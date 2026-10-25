# Universal links / App Links (deferred, docs/09 M5.0)

`dottoday://` works on every platform today. `https://dottoday.app/task/<id>`
links additionally need the paid Apple account and the Play upload key
(release gates, docs/08 §6.1 D):

1. Serve these two files at `https://dottoday.app/.well-known/`
   (`apple-app-site-association` with no extension, `application/json`),
   with the team id and the Play App Signing SHA-256 filled in; the app ids
   are already in.
2. iOS/macOS: add `applinks:dottoday.app` to the Associated Domains entitlement
   (Personal Teams can't sign this capability).
3. Android: add an `autoVerify="true"` intent filter for `https://dottoday.app`
   next to the `dottoday` one in `AndroidManifest.xml`.

The router already accepts the same paths, so no Dart change is needed.
