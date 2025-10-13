import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/symptom_request.dart';
import '../domain/models/symptom_response.dart';
import '../domain/models/skin_request.dart';
import '../domain/models/skin_response.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({this.baseUrl = 'http://10.216.112.33:5000', http.Client? client})
    : _client = client ?? http.Client();

  Future<SymptomResponse> checkSymptoms(SymptomRequest requestData) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/symptom-check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SymptomResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        throw const FormatException('Invalid symptom data provided');
      } else if (response.statusCode == 404) {
        throw const FormatException('Symptom check endpoint not found');
      } else if (response.statusCode == 500) {
        throw const FormatException('Server error during symptom analysis');
      } else {
        throw FormatException(
          'Failed to analyze symptoms. Status code: ${response.statusCode}',
        );
      }
    } on FormatException catch (e) {
      throw FormatException('Error parsing response: ${e.message}');
    } catch (e) {
      throw Exception('Error checking symptoms: $e');
    }
  }

  Future<SkinResponse> classifySkinImage(SkinRequest requestData) async {
    try {
      final uri = Uri.parse('$baseUrl/api/skin-classify');

      // Prepare multipart request
      final multipartRequest = http.MultipartRequest('POST', uri);

      final imageFile = requestData.imageFile;
      if (!await imageFile.exists()) {
        throw const FormatException('Image file does not exist');
      }

      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      );
      multipartRequest.files.add(multipartFile);

      // Use underlying client to send the multipart request
      final streamedResponse = await _client.send(multipartRequest);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SkinResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        throw const FormatException('Invalid image data provided');
      } else if (response.statusCode == 404) {
        throw const FormatException('Skin classify endpoint not found');
      } else if (response.statusCode == 500) {
        throw const FormatException('Server error during skin classification');
      } else {
        throw FormatException(
          'Failed to classify image. Status code: ${response.statusCode}',
        );
      }
    } on FormatException catch (e) {
      throw FormatException('Error parsing response: ${e.message}');
    } catch (e) {
      throw Exception('Error classifying skin image: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
