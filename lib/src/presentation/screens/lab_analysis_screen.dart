import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';
import '../../domain/models/lab_analysis_models.dart';

class LabAnalysisScreen extends StatefulWidget {
  const LabAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<LabAnalysisScreen> createState() => _LabAnalysisScreenState();
}

class _LabAnalysisScreenState extends State<LabAnalysisScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isAnalyzing = false;
  LabAnalysisResponse? _analysisResult;
  String? _error;

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error selecting image: $e';
      });
    }
  }

  Future<void> _analyzeLabReport() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final response = await _apiService.analyzeLabReport(_selectedImage!);
      setState(() {
        _analysisResult = response;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error analyzing lab report: $e';
        _isAnalyzing = false;
      });
    }
  }

  void _resetAnalysis() {
    setState(() {
      _selectedImage = null;
      _analysisResult = null;
      _error = null;
    });
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Lab Report Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Report Analysis'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorWidget();
    }
    
    if (_analysisResult != null) {
      return _buildResultsWidget();
    }
    
    return _buildImageSelectionWidget();
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _error = null;
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelectionWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Image display area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No lab report selected',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select a lab report image for AI analysis',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Select/Change image button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showImageSourceDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    icon: Icon(_selectedImage == null ? Icons.add_photo_alternate : Icons.change_circle),
                    label: Text(_selectedImage == null ? 'Select Lab Report' : 'Change Lab Report'),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Analyze button (only shown when image is selected)
                if (_selectedImage != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeLabReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      icon: _isAnalyzing 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.analytics),
                      label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Lab Report'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image thumbnail
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Lab Report Analysis',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          
          if (_analysisResult?.filename != null) ...[
            const SizedBox(height: 4),
            Text(
              'File: ${_analysisResult!.filename}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          
          const SizedBox(height: 16),

          if (_analysisResult!.success && _analysisResult!.analysis != null && !_analysisResult!.analysis!.error)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary
                    if (_analysisResult!.analysis!.summary.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Summary',
                        content: _analysisResult!.analysis!.summary,
                        icon: Icons.summarize,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Key Findings
                    if (_analysisResult!.analysis!.keyFindings.isNotEmpty) ...[
                      _buildKeyFindingsCard(_analysisResult!.analysis!.keyFindings),
                      const SizedBox(height: 12),
                    ],
                    
                    // Interpretation
                    if (_analysisResult!.analysis!.interpretation.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Interpretation',
                        content: _analysisResult!.analysis!.interpretation,
                        icon: Icons.psychology,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Note
                    if (_analysisResult!.analysis!.note.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'Important Note',
                        content: _analysisResult!.analysis!.note,
                        icon: Icons.warning,
                        color: Colors.amber,
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      _analysisResult?.analysis?.message ?? 
                      _analysisResult?.detail ?? 
                      'Analysis failed',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('Analyze Another Report'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyFindingsCard(List<String> findings) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.fact_check, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  'Key Findings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...findings.map((finding) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      finding,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
