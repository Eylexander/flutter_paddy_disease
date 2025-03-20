import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum ModelType { local, online }

class LocalModelInfo {
  final String name;
  final String modelFileName;
  final String labelsFileName;
  final String description;

  LocalModelInfo({
    required this.name,
    required this.modelFileName,
    required this.labelsFileName,
    required this.description,
  });

  @override
  String toString() {
    return 'LocalModelInfo(name: $name, modelFileName: $modelFileName, labelsFileName: $labelsFileName, description: $description)';
  }
}

class OnlineModelInfo {
  final String name;
  final String url;

  OnlineModelInfo({required this.name, required this.url});

  @override
  String toString() {
    return 'OnlineModelInfo(name: $name, url: $url)';
  }
}

class ModelProvider extends ChangeNotifier {
  List<LocalModelInfo> _availableLocalModels = [];
  int _selectedLocalModelIndex = 0;

  List<OnlineModelInfo> _availableOnlineModels = [];
  int _selectedOnlineModelIndex = 0;
  bool _isLoading = true;
  ModelType _modelType = ModelType.local;

  List<LocalModelInfo> get availableLocalModels => _availableLocalModels;
  LocalModelInfo get selectedLocalModel =>
      _availableLocalModels[_selectedLocalModelIndex];
  int get selectedLocalModelIndex => _selectedLocalModelIndex;

  List<OnlineModelInfo> get availableOnlineModels => _availableOnlineModels;
  OnlineModelInfo get selectedOnlineModel =>
      _availableOnlineModels[_selectedOnlineModelIndex];
  int get selectedOnlineModelIndex => _selectedOnlineModelIndex;

  bool get isLoading => _isLoading;
  ModelType get modelType => _modelType;

  ModelProvider() {
    _loadAvailableLocalModels();
    _loadAvailableOnlineModels();
  }

  Future<void> _loadAvailableLocalModels() async {
    try {
      // Default model
      _availableLocalModels = [
        LocalModelInfo(
          name: 'Flower Model',
          modelFileName: 'model_fleur.tflite',
          labelsFileName: 'model_fleur_labels.txt',
          description: 'Identifies various types of flowers',
        ),
      ];

      // Scan the assets/models directory for additional models
      try {
        final manifestContent = await rootBundle.loadString(
          'AssetManifest.json',
        );
        final Map<String, dynamic> manifestMap = Map.from(
          manifestContent.isNotEmpty ? await json.decode(manifestContent) : {},
        );

        final modelFiles =
            manifestMap.keys
                .where(
                  (String key) =>
                      key.startsWith('assets/models/') &&
                      key.endsWith('.tflite'),
                )
                .toList();

        for (final modelFile in modelFiles) {
          final modelName = modelFile.split('/').last.replaceAll('.tflite', '');

          // Skip the default model which is already added
          if (modelName == 'model_fleur') continue;

          // Check if there's a corresponding labels file
          final labelsFile = 'assets/models/${modelName}_labels.txt';
          if (manifestMap.containsKey(labelsFile)) {
            _availableLocalModels.add(
              LocalModelInfo(
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
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
        )
        .join(' ');
  }

  void setModelType(ModelType type) {
    _modelType = type;
    if (type == ModelType.local) {
      selectLocalModel(_selectedLocalModelIndex);
    }
    if (type == ModelType.online) {
      selectOnlineModel(_selectedOnlineModelIndex);
    }

    notifyListeners();
  }

  void selectLocalModel(int index) {
    if (index >= 0 && index < _availableLocalModels.length) {
      _selectedLocalModelIndex = index;

      debugPrint("Current model changed to : ${selectedLocalModel.name}");

      notifyListeners();
    }
  }

  Future<void> _loadAvailableOnlineModels() async {
    try {
      _availableOnlineModels = [
        OnlineModelInfo(
          name: "Animals Classifier",
          url: "https://dielz-animals-classifier-demo.hf.space/call/predict",
        ),
        OnlineModelInfo(
          name: "Car logo classifier",
          url:
              "https://markvosko-car-logo-classifier.hf.space/call/predict_image",
        )
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading models: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectOnlineModel(int index) {
    if (index >= 0 && index < _availableOnlineModels.length) {
      _selectedOnlineModelIndex = index;

      debugPrint("Current model changed to : ${selectedOnlineModel.name}");

      notifyListeners();
    }
  }
}
