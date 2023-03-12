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

  bool isLoading = true;
  bool isLoadingCropper = false;
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

  Future<bool> _onNavBack() async {
    setState(() {});
    return true;
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: onTakeImage,
                            child: Icon(Icons.camera_alt,
                                color: Color.fromARGB(255, 70, 122, 196))),
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
    turnOffFlash();
    final imageBytes = await xFile.readAsBytes();
    toggleLoadingCropper();
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (context) => CropperScreen(imageBytes: imageBytes)),
    );
    turnOnFlash();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleFlash() {
    setState(() {
      if (flashOn) {
        turnOffFlash();
      } else {
        turnOnFlash();
      }
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

  void turnOnFlash() {
    flashOn = true;
    _controller.setFlashMode(FlashMode.torch);
  }

  void turnOffFlash() {
    flashOn = false;
    _controller.setFlashMode(FlashMode.off);
  }
}
