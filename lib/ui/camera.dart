import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/geo_utils.dart';
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

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    initializeCameras();
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
            : Column(
                children: [
                  CameraPreview(_controller),
                  if (ocrResult != null) Text(ocrResult!),
                  ElevatedButton(
                      onPressed: onTakeImage, child: Text('Take picture')),
                ],
              );
      },
    );
  }

  void initializeCameras() async {
    final userLocation = await getUserLocation();

    final cameras = await availableCameras();
    if (cameras.length > 0) {
      _controller = CameraController(cameras[0], ResolutionPreset.low);
      _initializeControllerFuture = _controller.initialize();

      setState(() {
        isLoading = false;
      });
    } else {
      final isGranted = await Permission.camera.request().isGranted;
      if (isGranted) {
        initializeCameras();
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
    Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (context) =>
              CropperScreen(image: Image.file(File(this.image!.path)))),
    );

    setState(() {
      image = xFile;
    });
  }

  dynamic onLatestImageAvailable(CameraImage cameraImage) async {
    if (ocrResult != null) {
      print('TEXT: $ocrResult');
    }
    setState(() {
      // ocrResult = text;
    });
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
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
