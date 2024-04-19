import 'dart:convert';

import 'package:VehiLoc/core/model/response_vehicles.dart';
import 'package:VehiLoc/features/auth/login/login_view.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';

WebSocketChannel connectToWebSocket(String param) {
  List<dynamic> data = json.decode(param);
  var combineData = data.join(",");
  WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://vehiloc.net/sub-split/$combineData'),
  );
  return channel;
}

class WebSocketProvider {
  static final Logger logger = Logger();
  static WebSocketChannel? channel;
  static List<void Function(Vehicle)> subs = [];

  static void subscribe(void Function(Vehicle) cb) {
    if (subs.isEmpty) {
      connect();
    }
    subs.add(cb);
  }

  static void unsubscribe(void Function(Vehicle) cb) {
    subs.removeWhere((element) => element == cb);

    if (subs.isEmpty) {
      disconnect();
    }
  }

  static void dispose() {
    subs.clear();
    disconnect();
    logger.i("Disposing websocket");
  }

  static void connect() {
    if (channel != null) {
      logger.w("Attempt reconnect on existing channel");
      return;
    }

    List<dynamic> jsonRaw = json.decode(LoginState.userSalt);
    var saltFragment = jsonRaw.join(",");
    channel = WebSocketChannel.connect(
      Uri.parse('wss://vehiloc.net/sub-split/$saltFragment'),
    );

    channel?.stream.listen((event) {
      for (var sub in subs) {
        try {
          var vehicleRaw = json.decode(event);
          Vehicle vehicle = Vehicle.fromJson(vehicleRaw);
          sub(vehicle);
        } catch (e, t) {
          logger.w(t);
          logger.e("Subscriber error: $e");
        }
      }
    },
    onError: (error) {
      logger.e('Error: $error');
    },
    onDone: () {
      logger.i('WebSocket closed');
    },);
  }

  static void disconnect() {
    channel?.sink.close();
    channel = null;
  }
}