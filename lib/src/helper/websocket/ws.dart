import 'dart:async';
import 'package:web_socket_channel/io.dart';

bool _isConnected = false;

class WebSocketService {
  final String _url;
  late IOWebSocketChannel _webSocketChannel;
  var pingCounter = 0;

  WebSocketService(this._url);

  void ping() {
    // send a message to the server every 5 seconds
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (_isConnected) {
        _webSocketChannel.sink.add("ping");
        // every seccond increase the counter
        // if the counter is 10, reconnect the websocket
        pingCounter++;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> connect() async {
    ping();
    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (pingCounter == 3) {
        print("WS_reconnect");
        _isConnected = false;
        await reconnect();
      }
    });
    try {
      _webSocketChannel = IOWebSocketChannel.connect(_url);
      _isConnected = true;
      _webSocketChannel.stream.listen((event) async {
        //TODO: Do something with the received data
        if (event == "pong") {
          print("WS_active");
          pingCounter = 0;
        }
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
