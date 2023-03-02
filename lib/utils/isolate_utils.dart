import 'dart:async';
import 'dart:isolate';

import 'package:easy_isolate/easy_isolate.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../classifier/classifier.dart';
import 'image_utils.dart';

class PredictionWorker {
  final worker = Worker();
  final _predictionStreamController = StreamController<List<int>>();

  Future<void> init(PredictionEvent data) async {
    await worker.init(
      mainHandler,
      isolateHandler,
    );

    //Send to isolate thread
    worker.sendMessage(data);
  }

  void mainHandler(dynamic data, SendPort isolateSendPort) {
    //Handle incoming data from isolate thread
    if (data != null && data is Recognition) {
      print('MAIN HANDLER: ${data.label}');
      final snippetResult =
          ImageUtils.createSnippet(data.locations[0], data.originalImage);
      if (snippetResult != null) _predictionStreamController.add(snippetResult);
    }
    worker.dispose();
  }

  static void isolateHandler(
      dynamic data, SendPort mainSendPort, SendErrorFunction onSendError) {
    //Handle incoming data from main thread
    if (data is PredictionEvent) {
      ;
      classifierTask(data).then((value) => {
            //Respond back to main thread
            if (value != null)
              mainSendPort.send(value)
            else
              mainSendPort.send(null)
          });
    }
    ;
  }

  static Future<Recognition?> classifierTask(PredictionEvent data) async {
    try {
      final classifier = await Classifier(
          interpreter: Interpreter.fromAddress(data._interpreterAddress),
          labels: data._labels);
      return classifier.predict(data._cameraImage);
    } catch (e) {
      print('Error: ' + e.toString());
      return null;
    }
  }

  Stream<List<int>> get predictionStream => _predictionStreamController.stream;
}

class PredictionEvent {
  final img.Image _cameraImage;
  final List<String> _labels;
  final int _interpreterAddress;

  PredictionEvent(
    img.Image cameraImage,
    List<String> labels,
    int interpreterAddress,
  )   : _cameraImage = cameraImage,
        _labels = labels,
        _interpreterAddress = interpreterAddress;
}
