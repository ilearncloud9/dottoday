import 'package:sqlite3/common.dart';

/// A [CommonSqlite3] that opens every database through sqlite3mc's
/// encrypting wrapper of [baseVfs] (`multipleciphers-<name>`), which
/// sqlite3mc registers next to each VFS. drift opens `/database` on the
/// default VFS, which would silently skip encryption (M2.9).
final class CipherVfsSqlite3 implements CommonSqlite3 {
  CipherVfsSqlite3(this._inner, String baseVfs)
    : _vfs = 'multipleciphers-$baseVfs';

  final CommonSqlite3 _inner;
  final String _vfs;

  @override
  CommonDatabase open(
    String filename, {
    String? vfs,
    OpenMode mode = OpenMode.readWriteCreate,
    bool uri = false,
    bool? mutex,
  }) => _inner.open(filename, vfs: _vfs, mode: mode, uri: uri, mutex: mutex);

  @override
  CommonDatabase openInMemory({String? vfs}) => _inner.openInMemory(vfs: vfs);

  @override
  Version get version => _inner.version;

  @override
  String? get tempDirectory => _inner.tempDirectory;

  @override
  set tempDirectory(String? value) => _inner.tempDirectory = value;

  @override
  void registerVirtualFileSystem(
    VirtualFileSystem vfs, {
    bool makeDefault = false,
  }) => _inner.registerVirtualFileSystem(vfs, makeDefault: makeDefault);

  @override
  void unregisterVirtualFileSystem(VirtualFileSystem vfs) =>
      _inner.unregisterVirtualFileSystem(vfs);
}
