class Data {
  final List<DataItem> data;
  final List<InputLogsItem> inputlogs;
  final List<JdetailsItem> jdetails;

  Data({required this.data, required this.inputlogs, required this.jdetails});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      data: (json['data'] as List<dynamic>?)
              ?.map((x) => DataItem.fromJson(x))
              .toList() ??
          [],
      inputlogs: (json['inputlogs'] as List<dynamic>?)
              ?.map((x) => InputLogsItem.fromJson(x))
              .toList() ??
          [],
      jdetails: (json['jdetails'] as List<dynamic>?)
              ?.map((x) => JdetailsItem.fromJson(x))
              .toList() ??
          [],
    );
  }
}

class DataItem {
  final int bearing;
  final int gpsdt;
  final int ioStates;
  final double latitude;
  final double longitude;
  final int speed;
  final int temp;
  final String colorBox;

  DataItem({
    required this.bearing,
    required this.gpsdt,
    required this.ioStates,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.temp,
  }) : colorBox = _calculateColorBox(speed);

  factory DataItem.fromJson(Map<String, dynamic> json) {
    return DataItem(
      bearing: json['bearing'] ?? 0,
      gpsdt: json['gpsdt'] ?? 0,
      ioStates: json['io_states'] ?? 0,
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      speed: json['speed'] ?? 0,
      temp: json['temp'] ?? 0,
    );
  }

  get boxNo => null;

  static String _calculateColorBox(int speed) {
    if (speed == 0) {
      return 'white';
    } else if (speed >= 5 && speed <= 10) {
      return 'green1';
    } else if (speed >= 11 && speed <= 15) {
      return 'green2';
    } else if (speed >= 16 && speed <= 20){
      return 'green3';
    } else if (speed >= 16 && speed <= 20){
      return 'green4';
    } else if (speed >= 21 && speed <= 25){
      return 'green5';
    } else if (speed >= 26 && speed <= 30){
      return 'green6';
    } else if (speed >= 31 && speed <= 35){
      return 'green7';
    } else if (speed >= 36 && speed <= 40){
      return 'green8';
    } else if (speed >= 41 && speed <= 45){
      return 'green9';
    } else if (speed >= 46 && speed <= 50){
      return 'green10';
    } else if (speed >= 51 && speed <= 55){
      return 'green11';
    } else if (speed >= 56 && speed <= 60){
      return 'green12';
    } else if (speed >= 61 && speed <= 65){
      return 'yellow1';
    } else if (speed >= 66 && speed <= 70){
      return 'yellow2';
    } else if (speed >= 71 && speed <= 75){
      return 'yellow3';
    } else if (speed >= 76 && speed <= 80){
      return 'yellow4';
    } else if (speed >= 81 && speed <= 85){
      return 'yellow5';
    } else if (speed >= 86 && speed <= 90){
      return 'yellow6';
    } else if (speed >= 91 && speed <= 95){
      return 'yellow7';
    } else if (speed >= 96 && speed <= 100 ){
      return 'yellow8';
    } else {
      return 'red';
    }
  }
}

class InputLogsItem {
  final int dt;
  final int inputNo;
  final bool newState;
  final String newStateBgcolor;
  final String newStateDesc;
  final String sensorName;
  final int vehicleId;

  InputLogsItem({
    required this.dt,
    required this.inputNo,
    required this.newState,
    required this.newStateBgcolor,
    required this.newStateDesc,
    required this.sensorName,
    required this.vehicleId,
  });

  factory InputLogsItem.fromJson(Map<String, dynamic> json) {
    return InputLogsItem(
      dt: json['dt'] ?? 0,
      inputNo: json['input_no'] ?? 0,
      newState: json['new_state'] ?? false,
      newStateBgcolor: json['new_state_bgcolor'] ?? '',
      newStateDesc: json['new_state_desc'] ?? '',
      sensorName: json['sensor_name'] ?? '',
      vehicleId: json['vehicle_id'] ?? 0,
    );
  }
}

class JdetailsItem {
  final double distance;
  final int enddt;
  final List<dynamic> geofences;
  final int gfid;
  final double lat;
  final double lon;
  final int startdt;
  final int type;

  JdetailsItem({
    required this.distance,
    required this.enddt,
    required this.geofences,
    required this.gfid,
    required this.lat,
    required this.lon,
    required this.startdt,
    required this.type,
  });

  factory JdetailsItem.fromJson(Map<String, dynamic> json) {
    return JdetailsItem(
      distance: json['distance']?.toDouble() ?? 0.0,
      enddt: json['enddt'] ?? 0,
      geofences: json['geofences'] ?? [],
      gfid: json['gfid'] ?? 0,
      lat: json['lat']?.toDouble() ?? 0.0,
      lon: json['lon']?.toDouble() ?? 0.0,
      startdt: json['startdt'] ?? 0,
      type: json['type'] ?? 0,
    );
  }
}
