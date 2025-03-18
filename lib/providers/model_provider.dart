import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ModelInfo {
  final String name;
  final String modelFileName;
  final String labelsFileName;
  final String description;

  ModelInfo({
    required this.name,
    required this.modelFileName,
    required this.labelsFileName,
    required this.description,
  });

  @override
  String toString() {
    return 'ModelInfo(name: $name, modelFileName: $modelFileName, labelsFileName: $labelsFileName, description: $description)';
  }
}

class ModelProvider extends ChangeNotifier {
  List<ModelInfo> _availableModels = [];
  int _selectedModelIndex = 0;
  bool _isLoading = true;

  List<ModelInfo> get availableModels => _availableModels;
  ModelInfo get selectedModel => _availableModels[_selectedModelIndex];
  int get selectedModelIndex => _selectedModelIndex;
  bool get isLoading => _isLoading;

  ModelProvider() {
    _loadAvailableModels();
  }

  Future<void> _loadAvailableModels() async {
    try {
      // Default model
      _availableModels = [
        ModelInfo(
          name: 'Flower Model',
          modelFileName: 'model_fleur.tflite',
          labelsFileName: 'model_fleur_labels.txt',
          description: 'Identifies various types of flowers',
        ),
      ];

      // Scan the assets/models directory for additional models
      try {
        final manifestContent = await rootBundle.loadString('AssetManifest.json');
        final Map<String, dynamic> manifestMap = Map.from(
          manifestContent.isNotEmpty ? 
          await json.decode(manifestContent) : {}
        );

        final modelFiles = manifestMap.keys
            .where((String key) => key.startsWith('assets/models/') && key.endsWith('.tflite'))
            .toList();

        for (final modelFile in modelFiles) {
          final modelName = modelFile.split('/').last.replaceAll('.tflite', '');
          
          // Skip the default model which is already added
          if (modelName == 'model_fleur') continue;
          
          // Check if there's a corresponding labels file
          final labelsFile = 'assets/models/${modelName}_labels.txt';
          if (manifestMap.containsKey(labelsFile)) {
            _availableModels.add(
              ModelInfo(
                name: _formatModelName(modelName),
                modelFileName: '$modelName.tflite',
                labelsFileName: '${modelName}_labels.txt',
                description: 'Custom TFLite model',
              ),
            );
          }
        debugPrint('Added custom TFLite model : $modelName');
        }
      } catch (e) {
        debugPrint('Error scanning for models: $e');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading models: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  String _formatModelName(String modelName) {
    // Convert snake_case or kebab-case to Title Case
    return modelName
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  void selectModel(int index) {
    if (index >= 0 && index < _availableModels.length) {
      _selectedModelIndex = index;

      debugPrint("Current model changed to : ${selectedModel.name}");

      notifyListeners();
    }
  }
}
