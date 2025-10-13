import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../domain/models/symptom_models.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final ApiService _apiService = ApiService();
  List<String> _availableSymptoms = [];
  final List<String> _selectedSymptoms = [];
  List<String> _filteredSymptoms = [];
  bool _isLoadingSymptoms = true;
  bool _isAnalyzing = false;
  SymptomCheckResponse? _analysisResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAvailableSymptoms();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSymptoms() async {
    try {
      final response = await _apiService.getAvailableSymptoms();
      if (response.success) {
        setState(() {
          _availableSymptoms = response.symptoms;
          _filteredSymptoms = _availableSymptoms;
          _isLoadingSymptoms = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Failed to load symptoms';
          _isLoadingSymptoms = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading symptoms: $e';
        _isLoadingSymptoms = false;
      });
    }
  }

  void _filterSymptoms(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSymptoms = _availableSymptoms;
      } else {
        _filteredSymptoms = _availableSymptoms
            .where(
              (symptom) => symptom.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final response = await _apiService.checkSymptoms(_selectedSymptoms);
      setState(() {
        _analysisResult = response;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error analyzing symptoms: $e';
        _isAnalyzing = false;
      });
    }
  }

  void _resetAnalysis() {
    setState(() {
      _selectedSymptoms.clear();
      _analysisResult = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Checker'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingSymptoms
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _analysisResult != null
          ? _buildResultsWidget()
          : _buildSymptomSelectionWidget(),
    );
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
                _isLoadingSymptoms = true;
              });
              _loadAvailableSymptoms();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomSelectionWidget() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: _filterSymptoms,
            decoration: const InputDecoration(
              labelText: 'Search symptoms',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),

        // Selected symptoms count
        if (_selectedSymptoms.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            color: Colors.teal.withOpacity(0.1),
            child: Text(
              'Selected: ${_selectedSymptoms.length} symptom${_selectedSymptoms.length == 1 ? '' : 's'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

        // Symptoms list
        Expanded(
          child: ListView.builder(
            itemCount: _filteredSymptoms.length,
            itemBuilder: (context, index) {
              final symptom = _filteredSymptoms[index];
              final isSelected = _selectedSymptoms.contains(symptom);

              return CheckboxListTile(
                title: Text(symptom),
                value: isSelected,
                onChanged: (_) => _toggleSymptom(symptom),
                activeColor: Colors.teal,
              );
            },
          ),
        ),

        // Analyze button
        if (_selectedSymptoms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeSymptoms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: _isAnalyzing
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
                    : const Text('Analyze Symptoms'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultsWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analysis Results',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Based on symptoms: ${_analysisResult!.inputSymptoms.join(', ')}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          if (_analysisResult!.success)
            Expanded(
              child: ListView.builder(
                itemCount: _analysisResult!.predictions.length,
                itemBuilder: (context, index) {
                  final prediction = _analysisResult!.predictions[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        child: Text('#${prediction.rank}'),
                      ),
                      title: Text(
                        prediction.disease,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'Confidence: ${prediction.confidencePercent}',
                      ),
                      trailing: CircularProgressIndicator(
                        value: prediction.confidence,
                        strokeWidth: 3,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.teal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  _analysisResult!.error ?? 'No predictions available',
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
              child: const Text('Check New Symptoms'),
            ),
          ),
        ],
      ),
    );
  }
}
