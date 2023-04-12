import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

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

  static img.Image upscaleImage(img.Image image, double scaleFactor) {
    // Neue Dimensionen ausrechnen
    final newWidth = (image.width * scaleFactor).round();
    final newHeight = (image.height * scaleFactor).round();

    // Bild skalieren
    final dstImage = img.copyResize(image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.cubic);

    // Bild zurückgeben
    return dstImage;
  }
}
