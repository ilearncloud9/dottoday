// Writing into a folder the person picked needs `dart:io`; the web never
// gets here (it downloads instead), so its build links a stub.
export 'folder_writer_stub.dart' if (dart.library.io) 'folder_writer_io.dart';
