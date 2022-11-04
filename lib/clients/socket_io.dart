import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants.dart';

class SocketClient {
  io.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    dynamic uri = defaultTargetPlatform == TargetPlatform.android
        ? kHostAndroid
        : kHostWeb;

    socket = io.io(uri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}
