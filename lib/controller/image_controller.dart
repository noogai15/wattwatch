import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageUtils {
  static Uint8List getCameraImageBytes(CameraImage cameraImage) {
    final allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    return bytes;
  }

  static Future<double> calculateLuminance(
      ByteData bytes, int width, int height) async {
    double sum = 0;
    int i = 0;

    while (i < bytes.lengthInBytes) {
      int alpha = (i + 3 < bytes.lengthInBytes) ? bytes.getUint8(i + 3) : 255;
      final color = Color.fromARGB(
        alpha,
        bytes.getUint8(i),
        bytes.getUint8(i + 1),
        bytes.getUint8(i + 2),
      );
      sum += color.computeLuminance();
      i += 4;
    }

    return sum / (width * height);
  }
}
