// Picks the native (SQLCipher file) or web (WASM/OPFS) executor at compile
// time; both expose the same `openAppDatabase` (docs/09 M2.1).
export 'connection_unsupported.dart'
    if (dart.library.ffi) 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart';
