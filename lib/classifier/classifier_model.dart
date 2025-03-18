import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierModel {
  final Interpreter interpreter;
  final List<int> inputShape;
  final List<int> outputShape;
  final TensorType inputType;
  final TensorType outputType;

  ClassifierModel({
    required this.interpreter,
    required this.inputShape,
    required this.outputShape,
    required this.inputType,
    required this.outputType,
  }) {
    // Set interpreter options
    interpreter.allocateTensors();
  }
}
