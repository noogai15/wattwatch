import 'dart:math';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

typedef ClassifierLabels = List<String>;

class Classifier {
  late ClassifierLabels _labels;
  late Interpreter _interpreter;

  static const String LABELS_FILE_NAME = 'labels.txt';
  static const String MODEL_FILE_NAME = 'detect.tflite';
  static const int INPUT_SIZE = 300;
  static const int NUM_RESULTS = 10;
  static const double THRESHOLD = 0.5;
  var _result = 'none';

  /// Shapes of output tensors
  late List<List<int>> _outputShapes;

  /// Types of output tensors
  late List<TfLiteType> _outputTypes;

  Classifier({Interpreter? interpreter, List<String>? labels}) {
    _loadModel(interpreter);
    _loadLabels(labels);
  }

  void _loadModel(Interpreter? interpreter) async {
    // #1
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(MODEL_FILE_NAME,
              options: InterpreterOptions()..threads = 4);

      final outputTensors = _interpreter.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];

      outputTensors.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      });
    } catch (e) {
      print('Error while creating interpreter: $e');
    }
  }

  Future<void> _loadLabels(ClassifierLabels? labels) async {
    _labels = labels ?? await FileUtil.loadLabels('assets/' + LABELS_FILE_NAME);
  }

  String trimLabel(String label) => label.substring(label.indexOf(' ')).trim();

  TensorImage? _preProcessInput(img.Image image) {
    if (_interpreter == null) {
      print('Interpreter is not initialized yet');
      return null;
    }
    TensorImage inputImage = TensorImage.fromImage(image);
    final padSize = max(inputImage.height, inputImage.width);
    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(padSize, padSize))
        .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
        .build();
    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  Recognition? predict(img.Image image) {
    print('Running prediction');
    print(
      'Image: ${image.width}x${image.height}, '
      'size: ${image.length} bytes',
    );

    // Load the image and convert it to TensorImage for TensorFlow Input
    final inputImage = _preProcessInput(image)!;

    print(
      'Pre-processed image: ${inputImage.width}x${inputImage.height}, '
      'size: ${inputImage.buffer.lengthInBytes} bytes',
    );

    // TensorBuffers for output tensors
    final outputLocations = TensorBufferFloat(_outputShapes[0]);
    final outputClasses = TensorBufferFloat(_outputShapes[1]);
    final outputScores = TensorBufferFloat(_outputShapes[2]);
    final numLocations = TensorBufferFloat(_outputShapes[3]);

    List<Object> inputs = [inputImage.buffer];

    Map<int, Object> outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };

    //TODO: Add inference time counter
    _interpreter.runForMultipleInputs(inputs, outputs);

    int resultsCount = min(NUM_RESULTS, numLocations.getIntValue(0));
    int labelOffset = 1;

    final locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: INPUT_SIZE,
      width: INPUT_SIZE,
    );

    for (int i = 0; i < resultsCount; i++) {
      // Prediction score
      final score = outputScores.getDoubleValue(i);

      // Label string
      final labelIndex = outputClasses.getIntValue(i) + labelOffset;
      final label = _labels.elementAt(labelIndex);

      if (score > THRESHOLD) {
        print('Recognized $label');
        final result = Recognition(
            score: score,
            locations: locations,
            label: label,
            originalImage: image);
        return result;
      }
    }
    return null;
  }

  //Getters
  Interpreter get interpreter => _interpreter;

  List<String> get labels => _labels;

  String get result => _result;
}

class Recognition {
  double score;
  List<Rect> locations;
  String label;
  img.Image originalImage;

  Recognition(
      {required this.score,
      required this.locations,
      required this.label,
      required this.originalImage});
}
