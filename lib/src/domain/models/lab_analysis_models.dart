// Lab Analysis Models
class LabAnalysisResult {
  final bool error;
  final String? message;
  final String summary;
  final List<String> keyFindings;
  final String interpretation;
  final String note;
  final String? rawResponse;

  LabAnalysisResult({
    required this.error,
    this.message,
    required this.summary,
    required this.keyFindings,
    required this.interpretation,
    required this.note,
    this.rawResponse,
  });

  factory LabAnalysisResult.fromJson(Map<String, dynamic> json) {
    return LabAnalysisResult(
      error: json['error'] ?? false,
      message: json['message'],
      summary: json['summary'] ?? '',
      keyFindings: json['key_findings'] != null
          ? List<String>.from(json['key_findings'])
          : [],
      interpretation: json['interpretation'] ?? '',
      note: json['note'] ?? '',
      rawResponse: json['raw_response'],
    );
  }
}

class LabAnalysisResponse {
  final bool success;
  final String? filename;
  final LabAnalysisResult? analysis;
  final String? detail; // For error messages

  LabAnalysisResponse({
    required this.success,
    this.filename,
    this.analysis,
    this.detail,
  });

  factory LabAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return LabAnalysisResponse(
      success: json['success'] ?? false,
      filename: json['filename'],
      analysis: json['analysis'] != null
          ? LabAnalysisResult.fromJson(json['analysis'])
          : null,
      detail: json['detail'],
    );
  }
}