import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:image/image.dart' as imgLib;
import 'package:path_provider/path_provider.dart';

import '../utils/counter_utils.dart';
import 'send_form.dart';

class CropperScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const CropperScreen({Key? key, required this.imageBytes}) : super(key: key);

  @override
  State<CropperScreen> createState() => _CropperScreenState();
}

class _CropperScreenState extends State<CropperScreen> {
  Uint8List? _imageBytes;
  imgLib.Image? _image;

  @override
  void initState() {
    super.initState();
    _imageBytes = widget.imageBytes;
    _image = imgLib.decodeImage(_imageBytes!);
  }

  final _controller = CropController();
  Uint8List? _croppedImageBytes;
  String? ocrResult = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff252837),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                  height: 600,
                  child: Crop(
                      baseColor: Colors.black,
                      maskColor: Color.fromARGB(167, 0, 0, 0),
                      image: _imageBytes!,
                      initialArea:
                          Rect.fromLTRB(0, 700, _image!.width.toDouble(), 900),
                      controller: _controller,
                      onCropped: (image) {
                        setState(() {
                          _croppedImageBytes = image;
                        });
                      })),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                children: [
                  ElevatedButton(
                    child: Text(_croppedImageBytes == null
                        ? 'Crop Image'
                        : 'Re-crop image'),
                    onPressed: () {
                      _controller.crop();
                    },
                  ),
                  if (_croppedImageBytes != null)
                    ElevatedButton(
                      onPressed: onConfirm,
                      child: Text('Confirm'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_croppedImageBytes != null)
                Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Image.memory(_croppedImageBytes!)),
            ],
          ),
        ),
      ),
    );
  }

  void onBack() {
    Navigator.pop(context);
  }

  Uint8List preprocessImg(imgLib.Image image, double lumTreshold) {
    // image = imgLib.grayscale(image);
    image = imgLib.luminanceThreshold(threshold: lumTreshold, image);
    image = imgLib.gaussianBlur(image, radius: 1);
    // imgLib.sobel(image, amount: 50);
    setState(() {
      _croppedImageBytes = imgLib.encodeBmp(image);
    });
    return imgLib.encodeBmp(image);
  }

  Future<String> ocrScan(Uint8List imageBytes) async {
    var tempImgPath = await prepareImage(
      imageBytes,
      0.5,
    );

    final args = <String, dynamic>{
      'psm': '6',
      'preserve_interword_spaces': '0',
      'oem': '1'
    };

    var ocrResult = await FlutterTesseractOcr.extractText(tempImgPath,
        args: args, language: 'digits');

    //Keep retrying OCR with different luminance threshold settings
    //(up to 0.5 cap) if no acceptable result was found
    if (needsRetry(ocrResult)) {
      for (var lum = 0.2; lum <= 0.5; lum += 0.05) {
        tempImgPath = await prepareImage(imageBytes, lum);
        ocrResult = await FlutterTesseractOcr.extractText(tempImgPath,
            args: args, language: 'digits');
        if (!needsRetry(ocrResult)) break;
      }
    }
    print('OCR RESULT: $ocrResult');
    setState(() {
      this.ocrResult = ocrResult;
    });
    return ocrResult;
  }

  Future<String> prepareImage(Uint8List imageBytes, double lumTreshhold) async {
    final tempImage = imgLib.decodeImage(imageBytes)!;
    final processedImgBytes = preprocessImg(tempImage, lumTreshhold);
    final tempDir = await getTemporaryDirectory();
    final tempImgDir = Directory('${tempDir.path}/images/');
    if (!await tempImgDir.exists()) await tempImgDir.create(recursive: true);
    final tempImgPath = '${tempImgDir.path}/tempImg.png';

    final tempFile = File(tempImgPath);
    await tempFile.writeAsBytes(processedImgBytes);
    return tempImgPath;
  }

  bool needsRetry(String ocrResult) {
    if (formatCounter(ocrResult) == null) return true;
    return false;
  }

  void onConfirm() async {
    final scanResult = await ocrScan(_croppedImageBytes!);
    final formatted = formatCounter(scanResult);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SendFormDialogue(formatted);
        });
  }
}
