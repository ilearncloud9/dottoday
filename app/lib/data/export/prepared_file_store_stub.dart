import 'package:dottoday/data/export/prepared_file.dart';

/// The web has no temporary files: it keeps the bytes and downloads them.
PreparedFileStore platformPreparedFileStore() => MemoryPreparedFileStore();
