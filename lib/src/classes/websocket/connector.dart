import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';

class DeckWebsocket extends ChangeNotifier {
  // DeckWebsocket websocket constructor
  late StreamController<String> _streamController;
  late IOWebSocketChannel _webSocketChannel;
  late String _url;
  bool _isConnected = false;
  bool _breakConnection = false;
  Timer? _reconnectTimer;

  String get url => _url;
  Stream<String> get stream => _streamController.stream;
  bool get isConnected => _isConnected;
  bool get breakConnection => _breakConnection;

  void setIsConnected(bool isConnected) {
    _isConnected = isConnected;
    notifyListeners();
  }

  void setBreakConnection(bool breakConnection) {
    _breakConnection = breakConnection;
    notifyListeners();
  }

  void set_url(String url) {
    _url = url;
  }

  void initConnection(String url) {
    set_url(url);
    connect(url);
  }

  void connect(String url) {
    try {
      _streamController = StreamController.broadcast();
      _webSocketChannel =
          IOWebSocketChannel.connect(url, pingInterval: Duration(seconds: 5));

      _webSocketChannel.stream.listen(
        (data) {
          if (!_isConnected) {
            setIsConnected(true);
          }

          _streamController.add(data);
          if (kDebugMode) {
            // Print every event in debug mode
            print("Received from websocket: $data");
          }
          // Handle the events
        },
        onError: (error) {
          if (kDebugMode) {
            print('WebSocket error: $error');
          }
          setIsConnected(false);
          _reconnect(url);
        },
        onDone: () {
          if (_breakConnection) {
            if (kDebugMode) {
              print("Intentional connection break");
            }
            _breakConnection = false;
            return;
          }
          if (_isConnected) {
            if (kDebugMode) {
              print('WebSocket closed unexpectedly... reconnecting');
            }
            setIsConnected(false);
            _reconnect(url);
          } else {
            if (kDebugMode) {
              print('WebSocket connection failed... reconnecting');
            }
            _reconnect(url);
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        setIsConnected(false);
        print(e);
      }
    }
  }

  void _reconnect(String url) {
    // Clear existing reconnect timer if it's active
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      _reconnectTimer!.cancel();
    }

    // Schedule a reconnect attempt after a delay
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (kDebugMode) {
        print('Attempting to reconnect...');
      }
      try {
        connect(url);
      } catch (e) {
        if (kDebugMode) {
          print('Error while reconnecting: $e');
        }
        _reconnect(url);
      }
    });
  }

  void send(data) async {
    _webSocketChannel.sink.add(data);
  }

  void disconnect() {
    _url = null.toString();
    _streamController.close();
    _reconnectTimer?.cancel();
    _webSocketChannel.sink.close();
    _breakConnection = true;

    notifyListeners();
  }
}
