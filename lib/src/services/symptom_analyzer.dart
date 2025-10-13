import 'dart:convert';
import 'package:http/http.dart' as http;

class SymptomAnalysis {
  final String potentialConditions;
  final String recommendation;
  final String urgency;

  SymptomAnalysis({
    required this.potentialConditions,
    required this.recommendation,
    required this.urgency,
  });

  factory SymptomAnalysis.fromJson(Map<String, dynamic> json) {
    return SymptomAnalysis(
      potentialConditions: json['potential_conditions'].join(', '),
      recommendation: json['recommendation'],
      urgency: json['urgency'],
    );
  }
}

class SymptomAnalyzer {
  final String apiToken;
  final String baseUrl;

  SymptomAnalyzer({
    required this.apiToken,
    this.baseUrl =
        'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.1',
  });

  Future<SymptomAnalysis> analyzeSymptoms(String symptomsText) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': _createPrompt(symptomsText),
          'parameters': {
            'max_new_tokens': 500,
            'temperature': 0.3,
            'return_full_text': false,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to analyze symptoms: ${response.statusCode}');
      }

      return _parseResponse(response.body);
    } catch (e) {
      throw Exception('Error analyzing symptoms: $e');
    }
  }

  String _createPrompt(String symptomsText) {
    return '''You are an AI diagnostic assistant. Based on the following symptoms, 
    provide a structured analysis. Focus on being informative but cautious.

    Symptoms:
    $symptomsText

    Respond ONLY with a JSON object in this exact format:
    {
        "potential_conditions": ["condition1", "condition2"],
        "recommendation": "brief medical advice",
        "urgency": "Low/Medium/High"
    }

    Remember: This is for initial guidance only, not a final diagnosis.''';
  }

  SymptomAnalysis _parseResponse(String responseBody) {
    try {
      // Extract JSON from response
      final jsonStart = responseBody.indexOf('{');
      final jsonEnd = responseBody.lastIndexOf('}') + 1;

      if (jsonStart == -1 || jsonEnd == 0) {
        throw FormatException('No JSON object found in response');
      }

      final jsonStr = responseBody.substring(jsonStart, jsonEnd);
      final parsed = jsonDecode(jsonStr);

      // Validate response structure
      if (!_isValidResponse(parsed)) {
        throw FormatException('Invalid response format');
      }

      return SymptomAnalysis.fromJson(parsed);
    } catch (e) {
      throw FormatException('Failed to parse response: $e');
    }
  }

  bool _isValidResponse(Map<String, dynamic> response) {
    return response.containsKey('potential_conditions') &&
        response.containsKey('recommendation') &&
        response.containsKey('urgency') &&
        response['potential_conditions'] is List &&
        response['urgency'] is String &&
        ['Low', 'Medium', 'High'].contains(response['urgency']);
  }
}
