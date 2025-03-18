import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';
import '../providers/model_provider.dart';
import '../styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildSocialIcon(
    BuildContext context, {
    required GestureTapCallback onTap,
    required IconData icon,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          color:
              themeProvider.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
        ),
        child: Icon(
          icon,
          size: 30,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: kAppBarTitleStyle),
        backgroundColor: kPrimaryRed,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme and Model Settings
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
                    'Appearance',
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(
                      'Dark Mode',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Switch between light and dark theme',
                      style: GoogleFonts.sora(fontSize: 14),
                    ),
                    value: themeProvider.isDarkMode,
                    onChanged: (_) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: kPrimaryRed,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Model Selection
          Consumer<ModelProvider>(
            builder: (context, modelProvider, child) {
              if (modelProvider.isLoading) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              if (modelProvider.availableModels.isEmpty) {
                return const SizedBox.shrink();
              }

              return Card(
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
                        'Model Selection',
                        style: GoogleFonts.sora(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Current Model: ${modelProvider.selectedModel.name}',
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        modelProvider.selectedModel.description,
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (modelProvider.availableModels.length > 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Model:',
                              style: GoogleFonts.sora(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            DropdownButton<int>(
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              value: modelProvider.selectedModelIndex,
                              items:
                                  modelProvider.availableModels
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        int index = entry.key;
                                        var model = entry.value;
                                        return DropdownMenuItem<int>(
                                          value: index,
                                          child: Text(model.name),
                                        );
                                      })
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  modelProvider.selectModel(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'Only one model available',
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // About section
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
                    'About Plant Guessr',
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Rebuilding the Plant Recognizer app from Kodeco’s TensorFlow Lite Tutorial for Flutter, I'm training a custom model with Teachable Machine, integrating TensorFlow Lite via tflite_flutter, and adding image classification. This enhances my machine learning and Flutter skills while creating an app that identifies plants from photos or gallery images—an exciting blend of AI and mobile development!",
                    style: GoogleFonts.sora(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Version 0.0.1',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Social Links
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
                    'Follow Us',
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialIcon(
                        context,
                        onTap: () {
                          _launchUrl('https://github.com/Eylexander');
                        },
                        icon: FontAwesomeIcons.github,
                      ),
                      _buildSocialIcon(
                        context,
                        onTap: () {
                          _launchUrl('https://eylexander.xyz');
                        },
                        icon: FontAwesomeIcons.dev,
                      ),
                      _buildSocialIcon(
                        context,
                        onTap: () {
                          Share.share(
                            '49RtgWN1sJX7dFHM1HGPibFi5nAyGcs4f5LBTbVgcKRkhEzKnckvSZm1FPSLo87ngKSpPyzHiBXy4Fmz5LV1pX2ZEHHZuzU',
                          );
                        },
                        icon: FontAwesomeIcons.monero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
