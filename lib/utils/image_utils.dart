import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// ImageUtils
class ImageUtils {
  /// Converts a [CameraImage] in YUV420 format
  /// to [img.Image] in RGB format
  static img.Image? convertCameraImage(CameraImage cameraImage) {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return convertYUV420ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return convertBGRA8888ToImage(cameraImage);
    } else {
      return null;
    }
  }

  /// Converts a [CameraImage] in BGRA888 format
  /// to [img.Image] in RGB format
  static img.Image convertBGRA8888ToImage(CameraImage cameraImage) {
    final image = img.Image.fromBytes(cameraImage.planes[0].width!,
        cameraImage.planes[0].height!, cameraImage.planes[0].bytes,
        format: img.Format.bgra);
    return image;
  }

  /// Converts a [CameraImage] in YUV420 format
  /// to [img.Image] in RGB format
  static img.Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final image = img.Image(width, height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;

        final y = cameraImage.planes[0].bytes[index];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data[index] = ImageUtils.yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  static Future<img.Image> convertXFiletoImage(XFile xFile) async {
    final bytes = await File(xFile.path).readAsBytes();
    final image = img.decodeImage(bytes)!;
    return image;
  }

  /// Convert a single YUV pixel to RGB
  static int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }

  static void saveImage(img.Image image, [int i = 0]) async {
    final jpeg = img.JpegEncoder().encodeImage(image);
    final appDir = await getTemporaryDirectory();
    final appPath = appDir.path;
    final fileOnDevice = File('$appPath/out$i.jpg');
    await fileOnDevice.writeAsBytes(jpeg, flush: true);
    print('Saved $appPath/out$i.jpg');
  }

  static List<int>? createSnippet(Rect location, img.Image image) {
    final left = location.left * 6.4;
    final top = location.top * 6.4;
    final right = location.right * 6.4;
    final bottom = location.bottom * 6.4;

    if (left < 0 || top < 0 || right < 0 || bottom < 0) return null;

    final boxWidth = (right.round() - left.round());
    final boxHeight = (bottom.round() - top.round());
    final snippet = img.Image(boxWidth, boxHeight);
    img.copyInto(
      snippet,
      image,
    );

    return img.encodePng(snippet);
  }
}
