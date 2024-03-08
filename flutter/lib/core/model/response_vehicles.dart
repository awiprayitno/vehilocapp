class Vehicle {
  String? customerName;
  String? name;
  String? plateNo;
  int? gpsdt;
  int? speed;
  double? lat;
  double? lon;
  int? vehicleId;
  int? type;
  int? baseMcc;
  int? bearing;
  List<Sensor>? sensors;
  bool isTapped = false;

  Vehicle({
    required this.customerName,
    required this.name,
    required this.plateNo,
    required this.gpsdt,
    this.speed = 0,
    required this.lat,
    required this.lon,
    required this.vehicleId,
    this.type,
    this.baseMcc,
    this.bearing,
    this.sensors,
  });

  Vehicle.fromJson(Map<String, dynamic> json) {
    customerName = json['customer_name'];
    name = json['name'];
    plateNo = json['plate_no'];
    gpsdt = json['gpsdt'];
    speed = json['speed'];
    lat = json['lat'];
    lon = json['lon'];
    vehicleId = json['vehicle_id'];
    type = json['type'];
    baseMcc = json['base_mcc'];
    bearing = json['bearing'];
    if (json['sensors'] != null) {
      sensors = <Sensor>[];
      json['sensors'].forEach((v) {
        sensors!.add(Sensor.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customer_name'] = customerName;
    data['name'] = name;
    data['plate_no'] = plateNo;
    data['gpsdt'] = gpsdt;
    data['speed'] = speed;
    data['lat'] = lat;
    data['lon'] = lon;
    data['vehicle_id'] = vehicleId;
    data['type'] = type;
    data['base_mcc'] = baseMcc;
    data['bearing'] = bearing;
    if (sensors != null) {
      data['sensors'] = sensors!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  void merge(Vehicle newVehicle) {
    baseMcc = newVehicle.baseMcc;
    speed = newVehicle.speed;
    sensors = newVehicle.sensors;
    lat = newVehicle.lat;
    lon = newVehicle.lon;
    gpsdt = newVehicle.gpsdt;
    bearing = newVehicle.bearing;
  }
}

class Sensor {
  String? bgColor;
  String? name;
  String? status;

  Sensor({
    this.bgColor,
    this.name,
    this.status,
  });

  Sensor.fromJson(Map<String, dynamic> json) {
    bgColor = json['bgcolor'];
    name = json['name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bgcolor'] = bgColor;
    data['name'] = name;
    data['status'] = status;
    return data;
  }
}
