import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:cropperx/cropperx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:image/image.dart' as imgLib;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'send_form.dart';

class CropperScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const CropperScreen({Key? key, required this.imageBytes}) : super(key: key);

  @override
  State<CropperScreen> createState() => _CropperScreenState();
}

class _CropperScreenState extends State<CropperScreen> {
  @override
  void initState() {
    super.initState();
    _imageBytes = widget.imageBytes;
  }

  final ImagePicker _picker = ImagePicker();
  final GlobalKey _cropperKey = GlobalKey(debugLabel: 'cropperKey');
  Uint8List? _imageBytes;
  final _controller = CropController();
  Uint8List? _croppedImageBytes;
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
                  child: Crop(
                      image: _imageBytes!,
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
                  ElevatedButton(
                      onPressed: onImagePicker, child: Text('Pick Image')),
                  if (_croppedImageBytes != null)
                    ElevatedButton(
                      onPressed: onConfirm,
                      child: Text('Confirm'),
                    ),
                  if (ocrResult != null) Text(ocrResult!)
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

  Uint8List preprocessImg(imgLib.Image image) {
    image = imgLib.grayscale(image);
    image = imgLib.luminanceThreshold(image);
    image = imgLib.gaussianBlur(image, radius: 1);
    imgLib.sobel(image, amount: 10);
    setState(() {
      _croppedImageBytes = imgLib.encodeBmp(image);
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

    final ocrResult =
        await FlutterTesseractOcr.extractText(tempImgPath, args: args);
    print('OCR RESULT: $ocrResult');
    setState(() {
      this.ocrResult = ocrResult;
    });
    return ocrResult;
  }

  void onConfirm() async {
    final scanResult = await ocrScan(_croppedImageBytes!);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SendFormDialogue(scanResult);
        });
  }

  void onImagePicker() async {
    final pickedImg = await _picker.pickImage(source: ImageSource.gallery);
    final bytes = await pickedImg!.readAsBytes();
    setState(() {
      _croppedImageBytes = bytes;
    });
  }
}
