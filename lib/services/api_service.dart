import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../src/domain/models/analysis_request.dart';
import '../src/domain/models/analysis_response.dart';
import '../src/domain/models/symptom_models.dart';
import '../src/domain/models/image_classification_models.dart';
import '../src/domain/models/lab_analysis_models.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'ApiException: $message (Status: $statusCode)'
      : 'ApiException: $message';
}

class ApiService {
  final String baseUrl;
  final http.Client _client;
  final Logger _logger;

  ApiService({String? baseUrl, http.Client? client, Logger? logger})
    : baseUrl = baseUrl ?? 'http://10.216.112.33:5000',
      _client = client ?? http.Client(),
      _logger = logger ?? Logger();

  Future<AnalysisResponse> analyzeReport(AnalysisRequest requestData) async {
    final url = Uri.parse('$baseUrl/analyze');

    try {
      _logger.d('Making POST request to $url');
      _logger.d('Request data: ${jsonEncode(requestData.toJson())}');

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestData.toJson()),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw ApiException('Request timed out after 30 seconds');
            },
          );

      _logger.d('Response status code: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          return AnalysisResponse.fromJson(jsonResponse);
        } on FormatException catch (e) {
          _logger.e('Failed to parse response body: ${e.toString()}');
          throw ApiException('Invalid response format from server');
        }
      } else {
        String message = 'Server error';
        try {
          final Map<String, dynamic> errorJson = jsonDecode(response.body);
          message = errorJson['message'] ?? message;
        } catch (_) {
          // If we can't parse the error message, use the default one
        }
        throw ApiException(message, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      _logger.e('Network error: ${e.toString()}');
      throw ApiException('Network error: Unable to connect to server');
    } on HttpException catch (e) {
      _logger.e('HTTP error: ${e.toString()}');
      throw ApiException('HTTP error: ${e.message}');
    } on FormatException catch (e) {
      _logger.e('Data formatting error: ${e.toString()}');
      throw ApiException('Data formatting error: ${e.message}');
    } catch (e) {
      _logger.e('Unexpected error: ${e.toString()}');
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  // Backend API URLs
  static const String symptomCheckerBaseUrl = 'http://localhost:8002';
  static const String imageClassifierBaseUrl = 'http://localhost:8000';
  static const String labAnalysisBaseUrl = 'http://localhost:8003';

  Future<AvailableSymptoms> getAvailableSymptoms() async {
    final url = Uri.parse('$symptomCheckerBaseUrl/api/symptoms');
    
    try {
      _logger.d('Getting available symptoms from $url');
      
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      _logger.d('Response status code: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return AvailableSymptoms.fromJson(jsonResponse);
      } else {
        throw ApiException('Failed to get symptoms', statusCode: response.statusCode);
      }
    } catch (e) {
      _logger.e('Error getting symptoms: ${e.toString()}');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get symptoms: ${e.toString()}');
    }
  }

  Future<SymptomCheckResponse> checkSymptoms(List<String> symptoms) async {
    final url = Uri.parse('$symptomCheckerBaseUrl/api/check-symptoms');
    
    try {
      _logger.d('Checking symptoms: $symptoms');
      
      final requestBody = jsonEncode({'symptoms': symptoms});
      
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 30));

      _logger.d('Response status code: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return SymptomCheckResponse.fromJson(jsonResponse);
      } else {
        throw ApiException('Failed to check symptoms', statusCode: response.statusCode);
      }
    } catch (e) {
      _logger.e('Error checking symptoms: ${e.toString()}');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to check symptoms: ${e.toString()}');
    }
  }

  // Image Classification API Methods
  Future<ImageClassificationResponse> classifyImage(File imageFile) async {
    final url = Uri.parse('$imageClassifierBaseUrl/api/classify');
    
    try {
      _logger.d('Classifying image: ${imageFile.path}');
      
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      _logger.d('Response status code: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ImageClassificationResponse.fromJson(jsonResponse);
      } else {
        throw ApiException('Failed to classify image', statusCode: response.statusCode);
      }
    } catch (e) {
      _logger.e('Error classifying image: ${e.toString()}');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to classify image: ${e.toString()}');
    }
  }

  // Lab Analysis API Methods
  Future<LabAnalysisResponse> analyzeLabReport(File labReportFile) async {
    final url = Uri.parse('$labAnalysisBaseUrl/api/analyze-lab');
    
    try {
      _logger.d('Analyzing lab report: ${labReportFile.path}');
      
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', labReportFile.path));
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamedResponse);

      _logger.d('Response status code: ${response.statusCode}');
      _logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return LabAnalysisResponse.fromJson(jsonResponse);
      } else {
        // Try to parse error message
        String errorMessage = 'Failed to analyze lab report';
        try {
          final Map<String, dynamic> errorJson = jsonDecode(response.body);
          errorMessage = errorJson['detail'] ?? errorMessage;
        } catch (_) {
          // Use default error message
        }
        throw ApiException(errorMessage, statusCode: response.statusCode);
      }
    } catch (e) {
      _logger.e('Error analyzing lab report: ${e.toString()}');
      if (e is ApiException) rethrow;
      throw ApiException('Failed to analyze lab report: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
