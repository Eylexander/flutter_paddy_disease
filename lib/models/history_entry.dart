import 'dart:io';
import '../classifier/classifier_category.dart';

class HistoryEntry {
  final String id;
  final String imagePath;
  final String label;
  final double accuracy;
  final List<ClassifierCategory> allResults;
  final DateTime timestamp;
  final String modelName;

  HistoryEntry({
    required this.id,
    required this.imagePath,
    required this.label,
    required this.accuracy,
    required this.allResults,
    required this.timestamp,
    required this.modelName,
  });

  // Check if the image file exists
  bool get imageExists => File(imagePath).existsSync();

  // Format the date and time
  String get formattedDate {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Convert to and from JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'label': label,
      'accuracy': accuracy,
      'allResults': allResults.map((result) => {
        'label': result.label,
        'score': result.score,
      }).toList(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'modelName': modelName,
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'],
      imagePath: json['imagePath'],
      label: json['label'],
      accuracy: json['accuracy'],
      allResults: (json['allResults'] as List).map((result) => 
        ClassifierCategory(result['label'], result['score'])
      ).toList(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      modelName: json['modelName'] ?? 'Unknown',
    );
  }
}
