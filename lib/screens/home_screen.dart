import 'dart:io';
import 'package:flower_ai_api/classifier/classifier_category.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../classifier/classifier.dart';
import '../models/history_entry.dart';
import '../huggingface/hugging_face_service.dart';
import 'dart:convert';
import '../providers/history_provider.dart';
import '../providers/model_provider.dart';
import '../styles.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String? title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAnalyzing = false;
  bool _isLoading = false;
  final picker = ImagePicker();
  File? _selectedImageFile;

  // ignore: prefer_typing_uninitialized_variables
  var historyEntry;

  Classifier? _classifier;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadClassifier(BuildContext context) async {
    if (_classifier != null) {
      _classifier!.close();
      _classifier = null;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final modelProvider = Provider.of<ModelProvider>(context, listen: false);
      final modelInfo = modelProvider.selectedLocalModel;

      debugPrint('Starting classifier loading process');
      debugPrint('Labels file path: ${modelInfo.labelsFileName}');
      debugPrint('Model file path: ${modelInfo.modelFileName}');

      final classifier = await Classifier.loadWith(
        labelsFileName: modelInfo.labelsFileName,
        modelFileName: modelInfo.modelFileName,
      );

      if (classifier == null) {
        debugPrint('Classifier initialization returned null');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      debugPrint('Classifier successfully loaded');
      setState(() {
        _classifier = classifier;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Error in _loadClassifier: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // 'Plant Guessr',
          widget.title ?? 'Plant Guessr',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).appBarTheme.titleTextStyle?.copyWith(fontSize: 48),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        toolbarHeight: kToolbarHeight * 2,
      ),
      body: Container(
        color: kVeryLightRed,
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Spacer(),
            const SizedBox(height: 20),
            buildPhotoView(),
            const SizedBox(height: 10),
            _buildResultView(context),
            const Spacer(flex: 5),
            _buildPickPhotoButton(
              title: 'Take a photo',
              source: ImageSource.camera,
            ),
            _buildPickPhotoButton(
              title: 'Pick from gallery',
              source: ImageSource.gallery,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget buildPhotoView() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        GestureDetector(
          onTap: () {
            if (!_isAnalyzing && !_isLoading) {
              _showImageSourceDialog(context);
            }
          },
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: kLightRed,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.2 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  (_selectedImageFile == null)
                      ? Center(
                        child: Text(
                          'Please pick a photo',
                          style: kAnalyzingTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      )
                      : Image.file(_selectedImageFile!, fit: BoxFit.cover),
            ),
          ),
        ),
        _buildAnalyzingText(),
      ],
    );
  }

  Widget _buildResultView(BuildContext context) {
    return Column(
      children: [
        if (historyEntry != null)
          ElevatedButton(
            onPressed: () {
              if (_selectedImageFile != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ResultScreen(
                          label: historyEntry.label,
                          accuracy: historyEntry.accuracy,
                          allResults: historyEntry.allResults,
                          imagePath: historyEntry.imagePath,
                        ),
                  ),
                );
              }
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(historyEntry.label, style: kResultTextStyle),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Accuracy: ${(historyEntry.accuracy * 100).toStringAsFixed(2)}%',
                    style: kResultRatingTextStyle,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPickPhotoButton({
    required ImageSource source,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          debugPrint('Button pressed for source: $source');
          _onPickPhoto(source);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkRed,
          padding: EdgeInsets.zero,
        ),
        child: SizedBox(
          width: 300,
          height: 50,
          child: Center(child: Text(title, style: kButtonTextStyle)),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _onPickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _onPickPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyzingText() {
    if (!_isAnalyzing) {
      return const SizedBox.shrink();
    }
    return Text('Analyzing...', style: kAnalyzingTextStyle);
  }

  void _setAnalyzing(bool flag) {
    setState(() {
      _isAnalyzing = flag;
    });
  }

  void _onPickPhoto(ImageSource source) async {
    try {
      debugPrint('Attempting to pick image from source: $source');
      final pickedFile = await picker.pickImage(source: source);
      debugPrint('PickedFile result: ${pickedFile?.path ?? "null"}');

      if (pickedFile == null) {
        debugPrint('No image selected');
        return;
      }

      final imageFile = File(pickedFile.path);
      debugPrint('Image file created: ${imageFile.path}');

      setState(() {
        _selectedImageFile = imageFile;
      });

      _analyzeImage(imageFile);
    } catch (e) {
      debugPrint('Error picking image: $e');
      // Optionally show an error message to the user
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _analyzeImage(File image) async {
    final modelProvider = Provider.of<ModelProvider>(context, listen: false);
    final historyProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );

    if (modelProvider.modelType == ModelType.local) {
      // Local model analysis
      if (_classifier == null) {
        await _loadClassifier(context);
      }

      if (_classifier == null) {
        debugPrint('Classifier is not initialized');
        return;
      }

      _setAnalyzing(true);

      try {
        final imageInput = img.decodeImage(image.readAsBytesSync())!;
        final resultCategories = _classifier!.predictAll(imageInput);
        final topCategory = resultCategories.first;

        final label = topCategory.label;
        final accuracy = topCategory.score;

        setState(() {
          _setAnalyzing(false);
        });

        historyEntry = HistoryEntry(
          id: const Uuid().v4(),
          imagePath: image.path,
          label: label,
          accuracy: accuracy,
          allResults: resultCategories,
          timestamp: DateTime.now(),
          modelName: modelProvider.selectedLocalModel.name,
        );

        await historyProvider.addEntry(historyEntry);
      } catch (e) {
        debugPrint('Error during image analysis: $e');
        _setAnalyzing(false);
      }
    } else if (modelProvider.modelType == ModelType.online) {
      // Online model analysis
      _setAnalyzing(true);

      try {
        final base64Image = base64Encode(image.readAsBytesSync());
        final apiUrl = modelProvider.selectedOnlineModel.url;
        final huggingFaceService = HuggingFaceService();

        final prediction = await huggingFaceService.makePrediction(
          base64Image,
          apiUrl,
        );

        List<Map<String, dynamic>> predictions = [];

        if (modelProvider.selectedOnlineModelIndex == 0) {
          final label = prediction['data'][0]['label'];
          final confidence =
              prediction['data'][0]['confidences'][0]['confidence'];

          predictions.add({"label": label, "confidence": confidence});
        } else if (modelProvider.selectedOnlineModelIndex == 1) {
          final regExp = RegExp(r"(\w+):\s([\d.]+)%");
          for (var match in regExp.allMatches(prediction['data'][0])) {
            predictions.add({
              "label": match.group(1)!,
              "confidence": double.parse(match.group(2)!) / 100,
            });
          }
        } else {
          throw Exception(
            'Invalid model index: ${modelProvider.selectedOnlineModelIndex}',
          );
        }

        _setAnalyzing(false);

        final topPrediction = predictions.reduce(
          (a, b) => a['confidence'] > b['confidence'] ? a : b,
        );
        final label = topPrediction['label'];
        final confidence = topPrediction['confidence'];

        historyEntry = HistoryEntry(
          id: const Uuid().v4(),
          imagePath: image.path,
          label: label,
          accuracy: confidence,
          allResults:
              predictions
                  .map((p) => ClassifierCategory(p['label'], p['confidence']))
                  .toList(),
          timestamp: DateTime.now(),
          modelName: modelProvider.selectedOnlineModel.name,
        );

        await historyProvider.addEntry(historyEntry);
      } catch (e) {
        debugPrint('Error during image analysis: $e');
        _setAnalyzing(false);
      }
    }

    // Navigate to result screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResultScreen(
              label: historyEntry.label,
              accuracy: historyEntry.accuracy,
              allResults: historyEntry.allResults,
              imagePath: historyEntry.imagePath,
            ),
      ),
    );
  }
}
