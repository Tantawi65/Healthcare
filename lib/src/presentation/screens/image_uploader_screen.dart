import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';
import '../../domain/models/image_classification_models.dart';

class ImageUploaderScreen extends StatefulWidget {
  const ImageUploaderScreen({super.key});

  @override
  State<ImageUploaderScreen> createState() => _ImageUploaderScreenState();
}

class _ImageUploaderScreenState extends State<ImageUploaderScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isAnalyzing = false;
  ImageClassificationResponse? _analysisResult;
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

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final response = await _apiService.classifyImage(_selectedImage!);
      setState(() {
        _analysisResult = response;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error analyzing image: $e';
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
          title: const Text('Select Image Source'),
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
        title: const Text('Medical Image Analysis'),
        backgroundColor: Colors.purple,
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
                      child: Image.file(_selectedImage!, fit: BoxFit.contain),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No image selected',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select an image for medical analysis',
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
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    icon: Icon(
                      _selectedImage == null
                          ? Icons.add_photo_alternate
                          : Icons.change_circle,
                    ),
                    label: Text(
                      _selectedImage == null ? 'Select Image' : 'Change Image',
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Analyze button (only shown when image is selected)
                if (_selectedImage != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeImage,
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.analytics),
                      label: Text(
                        _isAnalyzing ? 'Analyzing...' : 'Analyze Image',
                      ),
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
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Analysis Results',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),

          const SizedBox(height: 16),

          if (_analysisResult!.success && _analysisResult!.prediction != null)
            Expanded(
              child: Column(
                children: [
                  // Top prediction card
                  Card(
                    elevation: 4,
                    color: Colors.purple[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.medical_services,
                                color: Colors.purple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Primary Diagnosis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _analysisResult!.prediction!.topPrediction.label,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Confidence: ${_analysisResult!.prediction!.topPrediction.confidencePercent}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // All predictions
                  Text(
                    'All Predictions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: ListView.builder(
                      itemCount:
                          _analysisResult!.prediction!.allPredictions.length,
                      itemBuilder: (context, index) {
                        final prediction =
                            _analysisResult!.prediction!.allPredictions[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              child: Text('${index + 1}'),
                            ),
                            title: Text(
                              prediction.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Confidence: ${prediction.confidencePercent}',
                            ),
                            trailing: CircularProgressIndicator(
                              value: prediction.confidence,
                              strokeWidth: 3,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.purple,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  _analysisResult!.error ??
                      'No classification results available',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
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
              child: const Text('Analyze Another Image'),
            ),
          ),
        ],
      ),
    );
  }
}
