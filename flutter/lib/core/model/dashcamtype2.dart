class Dashcamtype2{
  int? code;
  dynamic data;
  String? message;
  Result? result;

  Dashcamtype2({this.code, this.data, this.message, this.result});

  Dashcamtype2.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'];
    message = json['message'];
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['data'] = this.data;
    data['message'] = message;
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class Result {
  String? urlCamera;
  String? vin;
  String? direction;
  String? gpsSpeed;
  String? gpsTime;
  String? lat;
  String? lng;
  String? plateNo;
  String? posType;
  String? satellite;

  Result(
      {this.urlCamera,
      this.vin,
      this.direction,
      this.gpsSpeed,
      this.gpsTime,
      this.lat,
      this.lng,
      this.plateNo,
      this.posType,
      this.satellite});

  Result.fromJson(Map<String, dynamic> json) {
    urlCamera = json['UrlCamera'];
    vin = json['VIN'];
    direction = json['direction'];
    gpsSpeed = json['gpsSpeed'];
    gpsTime = json['gpsTime'];
    lat = json['lat'];
    lng = json['lng'];
    plateNo = json['plateNo'];
    posType = json['posType'];
    satellite = json['satellite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UrlCamera'] = urlCamera;
    data['VIN'] = vin;
    data['direction'] = direction;
    data['gpsSpeed'] = gpsSpeed;
    data['gpsTime'] = gpsTime;
    data['lat'] = lat;
    data['lng'] = lng;
    data['plateNo'] = plateNo;
    data['posType'] = posType;
    data['satellite'] = satellite;
    return data;
  }
}
