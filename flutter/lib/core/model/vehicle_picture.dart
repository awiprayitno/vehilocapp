class VehiclePicture {
  List<Result>? result;

  VehiclePicture({this.result});

  VehiclePicture.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  int? gpsdt;
  double? lat;
  double? lon;
  String? picId;
  String? picOid;

  Result({this.gpsdt, this.lat, this.lon, this.picId, this.picOid});

  Result.fromJson(Map<String, dynamic> json) {
    gpsdt = json['gpsdt'];
    lat = json['lat'];
    lon = json['lon'];
    picId = json['pic_id'];
    picOid = json['pic_oid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gpsdt'] = gpsdt;
    data['lat'] = lat;
    data['lon'] = lon;
    data['pic_id'] = picId;
    data['pic_oid'] = picOid;
    return data;
  }
}
