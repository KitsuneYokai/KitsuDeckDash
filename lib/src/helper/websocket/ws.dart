import 'dart:async';
import 'package:web_socket_channel/io.dart';

bool _isConnected = false;

//TODO: add a checker to see if the websocket is connected
class WebSocketService {
  final String _url;
  late IOWebSocketChannel _webSocketChannel;

  WebSocketService(this._url);

  Future<void> connect() async {
    try {
      _webSocketChannel = IOWebSocketChannel.connect(_url);
      _isConnected = true;
      _webSocketChannel.stream.listen((event) {
        //TODO: Do something with the received data
        print(event);
      });
    } catch (e) {
      _isConnected = false;
      print('WebSocket connection error: $e');
    }
  }

  Future<void> disconnect() async {
    if (_webSocketChannel != null) {
      await _webSocketChannel.sink.close();
      _isConnected = false;
    }
  }

  Future<void> reconnect() async {
    if (!_isConnected) {
      await connect();
    }
  }

  bool isWebSocketConnected() {
    return _isConnected;
  }
}
