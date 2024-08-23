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

  static Future<void> subscribe(void Function(Vehicle) cb, List customerSalts) async {
    logger.d("customer salts");
    logger.i(customerSalts);
    if (subs.isEmpty) {
      try{
      connect(customerSalts);
      }catch(e){
        logger.e(e);
      }
    }
    subs.add(cb);
  }

  static Future<void> unsubscribe(void Function(Vehicle) cb) async {
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

  static void connect(List customerSalts) {
    if (channel != null) {
      logger.w("Attempt reconnect on existing channel");
      return;
    }

    //List<dynamic> jsonRaw = json.decode(LoginState.userSalt);
    var saltFragment = customerSalts.join(",");
    logger.i("salt fragment");
    //logger.i(LoginState.userSalt);
    logger.i(saltFragment);
    logger.i(customerSalts);
    channel = WebSocketChannel.connect(
      Uri.parse('wss://vehiloc.net/sub-split/$saltFragment'),
    );

    channel?.stream.listen((event) {
      logger.d("realtimes event");
      logger.i(event);
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