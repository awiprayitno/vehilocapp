import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;


networkImageToBase64(Uri imageUrl) async {
  http.Response response = await http.get(imageUrl);
  final bytes = response.bodyBytes;
  return (bytes != null ? base64Encode(bytes) : null);
}

imageAssetToBase64(String path) async {
  ByteData bytes = await rootBundle.load(path);
  var buffer = bytes.buffer;
  var m = base64.encode(Uint8List.view(buffer));
  return m;
}