import 'dart:io';

import 'package:cropperx/cropperx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:image/image.dart' as imgLib;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'send_form.dart';

class CropperScreen extends StatefulWidget {
  final Image image;
  const CropperScreen({Key? key, required this.image}) : super(key: key);

  @override
  State<CropperScreen> createState() => _CropperScreenState();
}

class _CropperScreenState extends State<CropperScreen> {
  @override
  void initState() {
    super.initState();
    _imageToCrop = widget.image;
  }

  final ImagePicker _picker = ImagePicker();
  final GlobalKey _cropperKey = GlobalKey(debugLabel: 'cropperKey');
  Image? _imageToCrop;
  Uint8List? _croppedImage;
  Uint8List? laplaceBytes;
  String? ocrResult = null;
  OverlayType _overlayType = OverlayType.rectangle;
  int _rotationTurns = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 500,
                child: _imageToCrop != null
                    ? Cropper(
                        cropperKey: _cropperKey,
                        overlayType: _overlayType,
                        aspectRatio: 5.2,
                        rotationTurns: _rotationTurns,
                        image: _imageToCrop!,
                      )
                    : const ColoredBox(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                children: [
                  ElevatedButton(
                    child: Text(
                        _croppedImage == null ? 'Crop Image' : 'Re-crop image'),
                    onPressed: () async {
                      final imageBytes = await Cropper.crop(
                        cropperKey: _cropperKey,
                      );

                      if (imageBytes != null) {
                        setState(() {
                          _croppedImage = imageBytes;
                        });
                      }
                    },
                  ),
                  if (_croppedImage != null)
                    ElevatedButton(
                      onPressed: onConfirm,
                      child: Text('Confirm'),
                    ),
                  if (ocrResult != null) Text(ocrResult!)
                ],
              ),
              const SizedBox(height: 16),
              if (_croppedImage != null)
                Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Image.memory(_croppedImage!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void onBack() {
    Navigator.pop(context);
  }

  Uint8List preprocessImg(imgLib.Image image) {
    image = imgLib.grayscale(image);
    image = imgLib.luminanceThreshold(image);
    image = imgLib.gaussianBlur(image, radius: 3);
    // imgLib.sobel(image);
    setState(() {
      _croppedImage = imgLib.encodeBmp(image);
    });
    return imgLib.encodeBmp(image);
  }

  Future<String> ocrScan(Uint8List imageBytes) async {
    imgLib.Image tempImage = imgLib.decodeImage(imageBytes)!;
    final processedImgBytes = preprocessImg(tempImage);
    final tempDir = await getTemporaryDirectory();
    final tempImgDir = Directory('${tempDir.path}/images/');
    if (!await tempImgDir.exists()) await tempImgDir.create(recursive: true);

    final tempImgPath = '${tempImgDir.path}/tempImg.png';

    final tempFile = File(tempImgPath);
    await tempFile.writeAsBytes(processedImgBytes);

    Map<String, dynamic> args = {
      'psm': '8',
      'tessedit_char_whitelist': '0123456789',
      'preserve_interword_spaces': '0'
    };
//     final inputImageSize =
//         Size(tempImage.width.toDouble(), tempImage.height.toDouble());

// //TODO: Maybe rotation???
//     final inputImage = InputImage.fromBytes(
//         bytes: imageBytes,
//         inputImageData: InputImageData(
//             planeData: null,
//             size: inputImageSize,
//             imageRotation: InputImageRotation.rotation0deg,
//             inputImageFormat: InputImageFormat.yuv420));

//     final recognized = await recognizer.processImage(inputImage);
//     InputImageFormatValue.fromRawValue();
    final ocrResult =
        await FlutterTesseractOcr.extractText(tempImgPath, args: args);
    print('OCR RESULT: $ocrResult');
    setState(() {
      this.ocrResult = ocrResult;
    });
    return ocrResult;
  }

  void onConfirm() async {
    final scanResult = await ocrScan(_croppedImage!);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SendFormDialogue(scanResult);
        });
  }
}
