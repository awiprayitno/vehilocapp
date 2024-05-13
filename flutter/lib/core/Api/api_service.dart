import 'dart:convert';
import 'package:VehiLoc/core/model/dashcamtype2.dart';
import 'package:VehiLoc/core/model/picture.dart';
import 'package:VehiLoc/core/model/vehicle_picture.dart';
import 'package:VehiLoc/core/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:VehiLoc/core/model/response_daily.dart';
import 'package:VehiLoc/core/model/response_vehicles.dart';
import 'package:VehiLoc/core/model/response_geofences.dart';
import 'package:VehiLoc/core/model/dashcamtype1.dart';

class ApiService {
  final String baseUrl = "https://vehiloc.net/rest/";
  final String baseUrlDashcam = "https://dev.vehiloc.net/api/v1.0/live_stream";

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
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': basicAuth},
      );

      logger.i("response fetch vehicle");
      logger.i(response.body);
      logger.i(username);
      logger.i(password);

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
    } catch (e, t) {
      logger.e("Error during API request: $e");
      logger.w(t);
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
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

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
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': basicAuth},
      );
      logger.i("response fetch geofence");
      logger.i(response.body);

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
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

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
  Future<Dashcamtype1> fetchDashcam(String imei) async {
    final String apiUrl = "https://vehiloc.net/api/v1.0/live_stream?vehicle_imei=$imei&type=1";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        logger.i("Dashcam list : $jsonResponse");
        final Dashcamtype1 dashcam = Dashcamtype1.fromJson(jsonResponse);
        return dashcam;
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      throw Exception('Error during API request: $e');
    }
  }

  Future<Dashcamtype2> fetchDashcamType2(String imei) async {
    final String apiUrl = "https://vehiloc.net/api/v1.0/live_stream?vehicle_imei=$imei&type=2";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        logger.i("Dashcam list : $jsonResponse");
        final Dashcamtype2 dashcam = Dashcamtype2.fromJson(jsonResponse);
        return dashcam;
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      throw Exception('Error during API request: $e');
    }
  }

  Future<VehiclePicture> fetchVehiclePicture(int vehicleId, int startDt, int endDt) async {
    final String apiUrl = "https://track.ibos.id/rest/get_vehicle_picture_metadata?vehicle_id=$vehicleId&startdt=$startDt&enddt=$endDt";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final String username = prefs.getString('username') ?? "";
      final String password = prefs.getString('password') ?? "";

      if (username.isEmpty || password.isEmpty) {
        logger.e("Username or password not found");
      }

      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        logger.i("Vehicle Picture Response: $jsonResponse");
        return VehiclePicture.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      throw Exception('Error during API request: $e');
    }
  }

  Future<Picture> fetchPicture(String picOid) async {
    final String apiUrl = "https://track.ibos.id/api/v1.0/img/$picOid";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        logger.i("Picture list : $jsonResponse");
        final Picture picture = Picture.fromJson(jsonResponse);
        return picture;
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      throw Exception('Error during API request: $e');
    }
  }
}
