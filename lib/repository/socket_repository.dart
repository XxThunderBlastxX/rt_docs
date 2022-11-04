import 'package:socket_io_client/socket_io_client.dart';

import '../clients/socket_io.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  void joinRoom(String documentId) {
    _socketClient.emit('join', documentId);
  }
}
