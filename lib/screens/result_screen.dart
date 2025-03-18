import 'dart:io';
import 'package:flutter/material.dart';
import '../styles.dart';
import '../classifier/classifier_category.dart';

class ResultScreen extends StatelessWidget {
  final String label;
  final double accuracy;
  final List<ClassifierCategory> allResults;
  final String imagePath;
  final bool fromHistory;

  const ResultScreen({
    super.key,
    required this.label,
    required this.accuracy,
    required this.allResults,
    required this.imagePath,
    this.fromHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Results', style: kAppBarTitleStyle),
        backgroundColor: kPrimaryRed,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image display
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                    ),
                  ],
                  ),
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                  ),
                ),
                ),
              const SizedBox(height: 24),
              
              // Main result
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Identified as',
                        style: TextStyle(
                          fontFamily: kMainFont,
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: kResultTextStyle.copyWith(
                          color: kPrimaryRed,
                          fontSize: 32,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Confidence: ${(accuracy * 100).toStringAsFixed(2)}%',
                        style: kResultRatingTextStyle.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // All results with progress bars
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Possibilities',
                        style: TextStyle(
                          fontFamily: kMainFont,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...allResults.take(4).map((result) => _buildResultProgressBar(result)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultProgressBar(ClassifierCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category.label,
                  style: TextStyle(
                    fontFamily: kMainFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(category.score * 100).toStringAsFixed(2)}%',
                style: TextStyle(
                  fontFamily: kMainFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: category.score,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              category.score > 0.7 ? kPrimaryRed : 
              category.score > 0.4 ? kLightRed : 
              kAccentColor,
            ),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}
