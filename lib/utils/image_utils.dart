import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class ImageUtils {
  static Uint8List getCameraImageBytes(CameraImage cameraImage) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    return bytes;
  }
}
