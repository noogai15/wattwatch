import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/styles_utils.dart';
import 'cropper.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({Key? key}) : super(key: key);

  @override
  CameraWidgetState createState() => CameraWidgetState();
}

class CameraWidgetState extends State<CameraWidget> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  late Canvas canvas;

  final ImagePicker _picker = ImagePicker();
  bool isLoading = true;
  bool isLoadingCropper = false;
  bool predicting = false;
  bool flashOn = true;

  @override
  void initState() {
    super.initState();
    initCameraController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        return isLoading
            ? Center(
                child: CircularProgressIndicator(color: textColorPrim),
              )
            : Container(
                color: Color(0xff252837),
                child: Column(
                  children: [
                    Stack(children: [
                      CameraPreview(
                        _controller,
                      ),
                      if (isLoadingCropper)
                        Positioned.fill(
                          child: Center(
                              child: Container(
                            color: Colors.black54,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )),
                        ),
                    ]),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: onImagePicker,
                            child: Icon(
                              FontAwesomeIcons.image,
                              color: textColorPrim,
                            )),
                        SizedBox(width: 12),
                        ElevatedButton(
                            onPressed: onTakeImage,
                            child:
                                Icon(Icons.camera_alt, color: textColorPrim)),
                        SizedBox(width: 12),
                        ElevatedButton(
                            onPressed: toggleFlash,
                            child: flashOn == true
                                ? Icon(
                                    Icons.flash_off,
                                    color: textColorPrim,
                                  )
                                : Icon(
                                    Icons.flash_on,
                                    color: textColorPrim,
                                  )),
                      ],
                    )
                  ],
                ),
              );
      },
    );
  }

  void initCameraController() async {
    final cameras = await availableCameras();
    if (cameras.length > 0) {
      _controller = CameraController(cameras[0], ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize();
      _controller.setFlashMode(FlashMode.torch);

      setState(() {
        isLoading = false;
      });
    } else {
      final isGranted = await Permission.camera.request().isGranted;
      if (isGranted) {
        initCameraController();
      } else {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No Camera Available'),
              content: const Text(
                  '''No camera available. Please make sure your device has a camera.'''),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'OK'),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        Navigator.pop(context);
      }
    }
  }

  void onTakeImage() async {
    toggleLoadingCropper();
    final xFile = await _controller.takePicture();
    if (flashOn) toggleFlash();
    final imageBytes = await xFile.readAsBytes();
    toggleLoadingCropper();
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (context) => CropperScreen(imageBytes: imageBytes)),
    );
    if (flashOn) toggleFlash();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleFlash() {
    setState(() {
      flashOn = !flashOn;
      _controller.setFlashMode(flashOn ? FlashMode.torch : FlashMode.off);
    });
  }

  void toggleLoadingCropper() {
    setState(() {
      if (isLoadingCropper) {
        isLoadingCropper = false;
      } else {
        isLoadingCropper = true;
      }
    });
  }

  void onImagePicker() async {
    final pickedImg = await _picker.pickImage(source: ImageSource.gallery);
    final bytes = await pickedImg!.readAsBytes();

    await Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (context) => CropperScreen(imageBytes: bytes)),
    );
  }
}
