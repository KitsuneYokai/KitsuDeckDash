import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';

import 'package:keyboard_invoker/keyboard_invoker.dart';

import '../../helper/macro/image.dart';
import 'device.dart';

class DeckWebsocket extends KitsuDeck {
  // DeckWebsocket websocket constructor
  late StreamController<String> _streamController;
  late IOWebSocketChannel _webSocketChannel;
  late String _url;
  bool _isConnected = false;
  bool _isSecured = false;
  bool _isAuthed = false;
  bool _breakConnection = false;
  Timer? _reconnectTimer;

  String get url => _url;
  Stream<String> get stream => _streamController.stream;
  bool get isConnected => _isConnected;
  bool get isSecured => _isSecured;
  bool get isAuthed => _isAuthed;
  bool get breakConnection => _breakConnection;

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
        (data) async {
          if (!_isConnected) {
            setIsConnected(true);
            _url = url;
          }
          _streamController.add(data);

          log("Received from websocket: $data");

          Map jsonData = jsonDecode(data);
          // if the deck is secured by a pin send the pin
          if (jsonData["event"] == "CLIENT_AUTH" &&
              jsonData["protected"] == true) {
            setIsSecured(true);
            log("SENDING CLIENT_AUTH 🔑");
            send(jsonEncode({"event": "CLIENT_AUTH", "auth_pin": pin}));
          }
          if (jsonData["event"] == "CLIENT_AUTH" &&
              jsonData["protected"] == false) {
            setPin("");
          }
          // if the auth was successful
          if (jsonData["event"] == "CLIENT_AUTH_SUCCESS") {
            setIsAuthed(true);
            _webSocketChannel.sink
                .add(jsonEncode({"event": "GET_MACROS", "auth_pin": pin}));
            _webSocketChannel.sink.add(
                jsonEncode({"event": "GET_MACRO_IMAGES", "auth_pin": pin}));
            log("CLIENT AUTH SUCCESS ✔️");
          } else if (jsonData["event"] == "CLIENT_AUTH_FAILED") {
            disconnect();
            log("CLIENT AUTH FAILED ❌", LogType.error);
          }

          // handle Macro Invoked event
          if (jsonData["event"] == "MACRO_INVOKED") {
            Map jsonAction = jsonDecode(jsonData["action"]);
            var keyboardInvoker = KeyboardInvoker();
            for (var key in jsonAction["action"]) {
              if (key["event"] == KeyType.keyDown.toString()) {
                keyboardInvoker.holdKey(key["code"]);
              } else if (key["event"] == KeyType.keyUp.toString()) {
                keyboardInvoker.releaseKey(key["code"]);
              } else if (key["event"] == KeyType.keyInvoke.toString()) {
                keyboardInvoker.invokeKey(key["code"]);
              }
            }
          }
          if (jsonData["event"] == "GET_MACROS") {
            if (jsonData["status"] == true) {
              List macros = [];
              for (var macro in jsonData["macros"]) {
                macros.add(macro);
              }
              setMacroData(macros);
              setIsMacroDataLoaded(true);
              notify();
            }
          }

          if (jsonData["event"] == "GET_MACRO_IMAGES") {
            setMacroImages(jsonData["images"]);
            await fetchImage(hostname, pin, macroData, macroImages);
            notify();
          }

          if (jsonData["event"] == "UPDATE_MACRO_LAYOUT") {
            setMacroData([]);
            setIsMacroDataLoaded(false);
            fetchMacroData(_webSocketChannel.sink, pin);
          }
          // Handle the events
        },
        onError: (error) {
          log('WebSocket error: $error', LogType.error);
          setIsConnected(false);
          _reconnect(url);
        },
        onDone: () {
          if (_breakConnection) {
            log("Intentional connection break");
            _breakConnection = false;
            return;
          }
          if (_isConnected) {
            log('WebSocket closed unexpectedly... reconnecting',
                LogType.warning);
            setIsConnected(false);
            _reconnect(url);
          } else {
            log('WebSocket connection failed... reconnecting', LogType.warning);
            _reconnect(url);
          }
        },
      );
    } catch (e) {
      setIsConnected(false);
      log('Error while connecting: $e', LogType.error);
      _reconnect(url);
    }
  }

  void _reconnect(String url) {
    // Clear existing reconnect timer if it's active
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      _reconnectTimer!.cancel();
    }

    // Schedule a reconnect attempt after a delay
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      log('Attempting to reconnect...', LogType.warning);
      try {
        connect(url);
      } catch (e) {
        log('Error while reconnecting: $e', LogType.error);
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
