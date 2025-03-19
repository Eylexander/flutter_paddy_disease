import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HuggingFaceService {
  Future<String> uploadImageToImgBB(String base64Image) async {
    final String imgBBUrl =
        'https://api.imgbb.com/1/upload?expiration=600&key=';
    final String imgBBapiKey = 'f670a6859dc3c1a12959535aaa355d9b';

    try {
      // First POST the image to ImgBB
      final response = await http.post(
        Uri.parse("$imgBBUrl$imgBBapiKey"),
        body: {
          'image': base64Image,
        },
      );

      // If image uploaded correctly
      if (response.statusCode == 200) {
        // We return the public URL of said image
        final responseData = jsonDecode(response.body);
        return responseData['data']['url'];
      } else {
        throw Exception(
            'Failed to upload image to ImgBB: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading image to ImgBB: $e');
    }
  }

  Future<Map<String, dynamic>> makePrediction(String base64Image, String apiUrl) async {
    try {
      // First upload the image to imgbb
      final imageUrl = await uploadImageToImgBB(base64Image);

      final firstRequest = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "data": [
            {"path": imageUrl}
          ]
        }),
      );

      if (firstRequest.statusCode != 200) {
        debugPrint(
            "Failed to upload image to imgbb: ${firstRequest.statusCode}\nResponse: ${firstRequest.body}");
        throw Exception(
            'Failed to upload image to imgbb: ${firstRequest.statusCode}\nResponse: ${firstRequest.body}');
      }

      var res = jsonDecode(firstRequest.body);
      var eventId = res['event_id'];

      final secondRequest = await http.get(Uri.parse("$apiUrl/$eventId"));

      if (secondRequest.statusCode == 200) {
        // Parse the response data
        var eventData = secondRequest.body
            .split('\n')
            .firstWhere((line) => line.startsWith('data: '))
            .replaceFirst('data: ', '"data": ');

        var predictionData = jsonDecode('{$eventData}');

        // Extract the label and confidence
        var label = predictionData['data'][0]['label'];
        var confidence =
            predictionData['data'][0]['confidences'][0]['confidence'];

        // Print the label and confidence
        debugPrint('Label: $label, Confidence: $confidence');

        return predictionData;
      } else {
        debugPrint(
            'Failed to get prediction result: ${secondRequest.statusCode}\nResponse: ${secondRequest.body}');
        throw Exception(
            'Failed to get prediction result: ${secondRequest.statusCode}\nResponse: ${secondRequest.body}');
      }
    } catch (e) {
      debugPrint('Error details: $e'); // Debug print
      throw Exception('Error making prediction: $e');
    }
  }
}
