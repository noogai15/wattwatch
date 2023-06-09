import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as imgLib;
import 'package:path_provider/path_provider.dart';

import '../../utils/counter_utils.dart';
import '../../utils/image_utils.dart';
import '../../utils/styles_utils.dart';
import '../dialogues/send_form_dialogue.dart';

class CropperScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const CropperScreen({Key? key, required this.imageBytes}) : super(key: key);

  @override
  State<CropperScreen> createState() => _CropperScreenState();
}

class _CropperScreenState extends State<CropperScreen> {
  Uint8List? _imageBytes;
  imgLib.Image? _image;
  bool loading = false;

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
      body: AbsorbPointer(
        absorbing: loading,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 600,
                      child: Crop(
                          baseColor: Colors.black,
                          maskColor: Color.fromARGB(167, 0, 0, 0),
                          image: _imageBytes!,
                          initialArea: Rect.fromLTRB(
                              0, 700, _image!.width.toDouble(), 900),
                          controller: _controller,
                          onCropped: (image) {
                            setState(() {
                              _croppedImageBytes = image;
                            });
                          }),
                    ),
                    loading
                        ? Positioned.fill(
                            child: Center(
                                child: Container(
                              color: Colors.black54,
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: textColorPrim),
                              ),
                            )),
                          )
                        : Container()
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ElevatedButton(
                          onPressed: _controller.crop,
                          child: Icon(
                            FontAwesomeIcons.cropSimple,
                            color: textColorPrim,
                          ),
                        ),
                        if (_croppedImageBytes != null)
                          Positioned(
                              top: 0,
                              bottom: 15,
                              right: 1,
                              child: Icon(
                                Icons.loop_outlined,
                                color: Colors.black87,
                                size: 24,
                              ))
                      ],
                    ),
                    SizedBox(width: 12),
                    if (_croppedImageBytes != null)
                      ElevatedButton(
                          onPressed: onConfirm,
                          child: Icon(
                            Icons.check,
                            color: textColorPrim,
                            size: 32,
                          )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onBack() {
    Navigator.pop(context);
  }

  Uint8List preprocessImg(imgLib.Image image, double lumTreshold) {
    image = ImageUtils.upscaleImage(image, 2);
    image = imgLib.luminanceThreshold(threshold: lumTreshold, image);
    image = imgLib.invert(image);
    image = imgLib.gaussianBlur(image, radius: 1);

    setState(() {
      _croppedImageBytes = imgLib.encodeBmp(image);
    });
    return imgLib.encodeBmp(image);
  }

  Future<String> ocrScan(Uint8List imageBytes) async {
    var tempImgPath = await prepareImg(
      imageBytes,
      0.3,
    );

    final args = <String, dynamic>{
      'psm': '6',
      'preserve_interword_spaces': '0',
      'oem': '1',
    };

    var ocrResult = await FlutterTesseractOcr.extractText(tempImgPath,
        args: args, language: 'digits');

    //Keep retrying OCR with different luminance threshold settings
    //(up to 0.5 cap) if no acceptable result was found
    if (needsRetry(ocrResult)) {
      for (var lum = 0.2; lum <= 0.5; lum += 0.05) {
        tempImgPath = await prepareImg(imageBytes, lum);
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

  Future<String> prepareImg(Uint8List imageBytes, double lumTreshhold) async {
    final tempImage = imgLib.decodeImage(imageBytes)!;
    final processedImgBytes = preprocessImg(tempImage, lumTreshhold);
    final tempImgPath = await saveToTempDir(await processedImgBytes, 'tempImg');
    return tempImgPath;
  }

  Future<String> saveToTempDir(Uint8List imageBytes, String name) async {
    final tempDir = await getTemporaryDirectory();
    final tempImgDir = Directory('${tempDir.path}/images');
    if (!await tempImgDir.exists()) await tempImgDir.create(recursive: true);
    final tempImgPath = '${tempImgDir.path}/${name}.png';
    final tempFile = File(tempImgPath);
    await tempFile.writeAsBytes(imageBytes);
    return tempFile.path;
  }

  bool needsRetry(String ocrResult) =>
      parseAndValidateCounter(ocrResult) == null;

  void onConfirm() async {
    setState(() => this.loading = true);
    final scanResult = await ocrScan(_croppedImageBytes!);
    setState(() => this.loading = false);
    final formatted = parseAndValidateCounter(scanResult);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SendFormDialogue(formatted);
        });
  }
}
