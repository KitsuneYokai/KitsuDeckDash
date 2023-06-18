import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';

import 'package:keypress_simulator/keypress_simulator.dart';

class DeckWebsocket extends ChangeNotifier {
  // DeckWebsocket websocket constructor
  late StreamController<String> _streamController;
  late IOWebSocketChannel _webSocketChannel;
  late String _url;
  late String _pin;
  bool _isConnected = false;
  bool _isSecured = false;
  bool _isAuthed = false;
  bool _breakConnection = false;
  Timer? _reconnectTimer;

  String get url => _url;
  Stream<String> get stream => _streamController.stream;
  String get pin => _pin;
  bool get isConnected => _isConnected;
  bool get isSecured => _isSecured;
  bool get isAuthed => _isAuthed;
  bool get breakConnection => _breakConnection;

  void setPin(String pin) {
    _pin = pin;
    notifyListeners();
  }

  void setIsConnected(bool isConnected) {
    _isConnected = isConnected;
    notifyListeners();
  }

  void setIsSecured(bool isSecured) {
    _isSecured = isSecured;
    notifyListeners();
  }

  void setIsAuthed(bool isAuthed) {
    _isAuthed = isAuthed;
    notifyListeners();
  }

  void setBreakConnection(bool breakConnection) {
    _breakConnection = breakConnection;
    notifyListeners();
  }

  void initConnection(String url, String pin) {
    connect(url);
    setPin(pin);
  }

  void connect(String url) {
    try {
      _streamController = StreamController.broadcast();
      _webSocketChannel = IOWebSocketChannel.connect(url,
          pingInterval: const Duration(seconds: 5));
      _webSocketChannel.stream.listen(
        (data) {
          if (!_isConnected) {
            setIsConnected(true);
            _url = url;
          }
          _streamController.add(data);
          if (kDebugMode) {
            // Print every event in debug mode
            print("Received from websocket: $data");
          }

          Map jsonData = jsonDecode(data);
          // if the deck is secured by a pin send the pin
          if (jsonData["event"] == "CLIENT_AUTH" &&
              jsonData["protected"] == true) {
            setIsSecured(true);
            if (kDebugMode) {
              print("Sending CLIENT_AUTH");
            }
            send(jsonEncode({"event": "CLIENT_AUTH", "auth_pin": _pin}));
          }
          if (jsonData["event"] == "CLIENT_AUTH" &&
              jsonData["protected"] == false) {
            setPin("");
          }
          // if the auth was successful
          if (jsonData["event"] == "CLIENT_AUTH_SUCCESS") {
            setIsAuthed(true);
            if (kDebugMode) {
              print("Client auth success");
            }
          } else if (jsonData["event"] == "CLIENT_AUTH_FAILED") {
            disconnect();
            if (kDebugMode) {
              print("Client auth failed");
            }
          }

          // handle Macro Invoked event
          if (jsonData["event"] == "MACRO_INVOKED") {
            Map jsonAction = jsonDecode(jsonData["action"]);

            Future.delayed(const Duration(milliseconds: 5), () async {
              await keyPressSimulator.requestAccess();
              for (var key in jsonAction["action"]) {
                // convert the key to LogicalKeyboardKey
                await keyPressSimulator.simulateKeyPress(
                  key: LogicalKeyboardKey.findKeyByKeyId(key["code"]),
                );
              }
            });
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
    _isConnected = false;
    notifyListeners();
  }
}
