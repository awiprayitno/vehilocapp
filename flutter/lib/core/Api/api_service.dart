import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:VehiLoc/core/model/response_daily.dart';
import 'package:VehiLoc/core/model/response_vehicles.dart';
import 'package:VehiLoc/core/model/response_geofences.dart';

class ApiService {
  final String baseUrl = "https://vehiloc.net/rest/";
  final Logger logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8, 
        lineLength: 120,
        colors: true, 
        printEmojis: true,
        printTime: true
        ),
  );

  Future<List<Vehicle>> fetchVehicles() async {
    final String apiUrl = "$baseUrl/vehicles";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final String username = prefs.getString('username') ?? "";
      final String password = prefs.getString('password') ?? "";

      if (username.isEmpty || password.isEmpty) {
        logger.e("Username or password not found");
        return [];
      }

      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final List<Vehicle> vehicles = jsonResponse
            .map((vehicleJson) => Vehicle.fromJson(vehicleJson))
            .cast<Vehicle>()
            .toList();
        logger.i("Vehicle response: $jsonResponse");
        return vehicles;
      } else {
        logger.e("API request failed with status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      logger.e("Error during API request: $e");
      return [];
    }
  }

  Future<Data> fetchDailyHistory(int vehicleId, int startEpoch) async {
    final String apiUrl =
        "$baseUrl/vehicle_daily_history/$vehicleId/$startEpoch";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final String username = prefs.getString('username') ?? "";
      final String password = prefs.getString('password') ?? "";

      if (username.isEmpty || password.isEmpty) {
        logger.e("Username or password not found");
      }

      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        logger.i("Vehicle Daily Response: $jsonResponse");
        return Data.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      throw Exception('Error during API request: $e');
    }
  }

  Future<List<Geofences>> fetchGeofences() async {
    final String apiUrl = "$baseUrl/geofences";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final String username = prefs.getString('username') ?? "";
      final String password = prefs.getString('password') ?? "";

      if (username.isEmpty || password.isEmpty) {
        logger.e("Username or password not found");
        return [];
      }

      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final List<Geofences> geofences = jsonResponse
            .map((geofenceJson) => Geofences.fromJson(geofenceJson))
            .cast<Geofences>()
            .toList();
        logger.i("Geofences response: $jsonResponse");
        return geofences;
      } else {
        logger.e("API request failed with status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      logger.e("Error during API request: $e");
      return [];
    }
  }

  Future<String> fetchAddress(double lat, double lon) async {
    final String apiUrl = "$baseUrl/address?lat=$lat&lon=$lon";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final String username = prefs.getString('username') ?? "";
      final String password = prefs.getString('password') ?? "";

      if (username.isEmpty || password.isEmpty) {
        logger.e("Username or password not found");
        return "";
      }

      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        logger.i("Address result : $jsonResponse");
        return jsonResponse['address'];
      } else {
        logger.e("API request failed with status code: ${response.statusCode}");
        return "";
      }
    } catch (e) {
      logger.e("Error during API request: $e");
      return "";
    }
  }
}
