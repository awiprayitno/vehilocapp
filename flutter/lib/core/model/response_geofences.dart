class Geofences {
  int? customerId;
  List<Geometry>? geometry;
  int? id;
  String? name;

  Geofences({this.customerId, this.geometry, this.id, this.name});

  Geofences.fromJson(Map<String, dynamic> json) {
    customerId = json['customer_id'];
    if (json['geometry'] != null) {
      geometry = <Geometry>[];
      json['geometry'].forEach((v) {
        geometry!.add(Geometry.fromJson(v));
      });
    }
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customer_id'] = customerId;
    if (geometry != null) {
      data['geometry'] = geometry!.map((v) => v.toJson()).toList();
    }
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class Geometry {
  double? latitude;
  double? longitude;

  Geometry({this.latitude, this.longitude});

  Geometry.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
