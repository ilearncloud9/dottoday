/// An in-memory app database for journeys that run in the real app on a
/// device or the Mac (docs/09 M20.4): nothing they do may open the
/// person's own database. The web's browser profile is thrown away after
/// each run, and drift's native database doesn't build there, so the web
/// keeps its own.
library;

export 'memory_database_stub.dart'
    if (dart.library.ffi) 'memory_database_native.dart';
