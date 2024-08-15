import 'package:flutter/material.dart';
import 'package:VehiLoc/core/model/response_vehicles.dart';
import 'package:VehiLoc/core/Api/api_service.dart';

class ApiProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  late Future<List<Vehicle>> _apiResponse;

  Future<List<Vehicle>> getApiResponse() {
    _apiResponse = _apiService.fetchAllVehicles();
    return _apiResponse;
  }
}
