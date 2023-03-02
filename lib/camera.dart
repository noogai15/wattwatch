import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'classifier/classifier.dart';
import 'utils/image_utils.dart';
import 'utils/isolate_utils.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({Key? key}) : super(key: key);

  @override
  CameraWidgetState createState() => CameraWidgetState();
}

class CameraWidgetState extends State<CameraWidget> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  late final Classifier classifier;
  late Canvas canvas;
  Uint8List? snippet = null;

  bool isLoading = true;
  bool predicting = false;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    initializeCameras();
    classifier = Classifier();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snippet != null)
          return Column(children: [
            Transform.rotate(
                angle: pi / 2,
                child: Image(
                  image: MemoryImage(snippet!),
                )),
            ElevatedButton(onPressed: onBack, child: Text('Back'))
          ]);
        return isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  CameraPreview(_controller),
                  ElevatedButton(
                      onPressed: onTakeImage, child: Text('Take picture')),
                ],
              );
      },
    );
  }

  void initializeCameras() async {
    final cameras = await availableCameras();
    if (cameras.length > 0) {
      _controller = CameraController(cameras[0], ResolutionPreset.high);
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
    final image = await ImageUtils.convertXFiletoImage(xFile);
    if (predicting) return;

    setState(() {
      predicting = true;
    });

    final worker = PredictionWorker();
    worker
        .init(PredictionEvent(
            image, classifier.labels, classifier.interpreter.address))
        .then(
          (result) => {
            setState(() {
              predicting = false;
            })
          },
        );
    worker.predictionStream.listen((result) {
      setState(() {
        snippet = result as Uint8List;
        print('Snippet found');
      });
    });
  }

  void stopImageStream() {
    _controller.stopImageStream();
    predicting = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onBack() {
    setState(() {
      snippet = null;
    });
  }
}
