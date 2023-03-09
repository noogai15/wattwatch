import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
  XFile? image = null;
  String? ocrResult;

  bool isLoading = true;
  bool predicting = false;
  bool flashOn = true;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
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
                child: CircularProgressIndicator(),
              )
            : Wrap(
                alignment: WrapAlignment.center,
                children: [
                  CameraPreview(_controller),
                  if (ocrResult != null) Text(ocrResult!),
                  ElevatedButton(
                    onPressed: onTakeImage,
                    child: Text(
                      'Take picture',
                      style:
                          TextStyle(color: Color.fromARGB(255, 70, 122, 196)),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  ElevatedButton(
                      onPressed: toggleFlash,
                      child: flashOn == true
                          ? Icon(
                              Icons.flash_off,
                              color: Color.fromARGB(255, 70, 122, 196),
                            )
                          : Icon(
                              Icons.flash_on,
                              color: Color.fromARGB(255, 70, 122, 196),
                            ))
                ],
              );
      },
    );
  }

  void initCameraController() async {
    final cameras = await availableCameras();
    if (cameras.length > 0) {
      _controller = CameraController(cameras[0], ResolutionPreset.low);
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
    final xFile = await _controller.takePicture();
    setState(() {
      image = xFile;
    });
    final imageBytes = await image!.readAsBytes();
    _controller.setFlashMode(FlashMode.off);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (context) => CropperScreen(imageBytes: imageBytes)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onBack() {
    setState(() {
      image = null;
    });
  }

  void toggleFlash() {
    setState(() {
      if (flashOn) {
        flashOn = false;
        _controller.setFlashMode(FlashMode.off);
      } else {
        flashOn = true;
        _controller.setFlashMode(FlashMode.torch);
      }
    });
  }
}
