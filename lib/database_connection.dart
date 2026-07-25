export 'database_connection_stub.dart'
    if (dart.library.io) 'database_connection_native.dart'
    if (dart.library.js_interop) 'database_connection_web.dart';
