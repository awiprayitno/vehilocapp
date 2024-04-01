class Carousel {
  List<String>? data;
  String? result;
  bool? success;

  Carousel({this.data, this.result, this.success});

  Carousel.fromJson(Map<String, dynamic> json) {
    data = json['data'].cast<String>();
    result = json['result'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['result'] = result;
    data['success'] = success;
    return data;
  }
}
