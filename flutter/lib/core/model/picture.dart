class Picture {
  String? b64data;
  int? gpsdt;
  double? lat;
  double? lon;
  String? mimetype;
  String? picId;
  String? picOid;

  Picture({
      this.b64data,
      this.gpsdt,
      this.lat,
      this.lon,
      this.mimetype,
      this.picId,
      this.picOid
    });

  Picture.fromJson(Map<String, dynamic> json) {
    b64data = json['b64data'];
    gpsdt = json['gpsdt'];
    lat = json['lat'];
    lon = json['lon'];
    mimetype = json['mimetype'];
    picId = json['pic_id'];
    picOid = json['pic_oid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['b64data'] = b64data;
    data['gpsdt'] = gpsdt;
    data['lat'] = lat;
    data['lon'] = lon;
    data['mimetype'] = mimetype;
    data['pic_id'] = picId;
    data['pic_oid'] = picOid;
    return data;
  }
}
