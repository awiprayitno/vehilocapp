import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'logger.dart';

const storage = FlutterSecureStorage();

class SpData{
  void savePrinter(String key, String? value) async {
    if (key != null && value != null){
      await storage.delete(key: key);
      await storage.write(key: key, value: value);
    } else {
      logger.d('Failed storing printer address (null)');
    }
  }

  Future<String?> loadPrinter() async {
    String? val = await storage.read(key: 'printerAddress');
    return val;
  }

  Future<void> resetPrinter() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    await storage.delete(key: 'printerAddress');
    //await prefs.clear();
  }
}


  final userProvider =
  StateProvider<Map>((ref) => {});



