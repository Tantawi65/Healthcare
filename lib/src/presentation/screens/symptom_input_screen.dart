import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/symptom_checker_bloc/symptom_checker_bloc.dart';
import '../bloc/symptom_checker_bloc/symptom_checker_event.dart';
import '../bloc/symptom_checker_bloc/symptom_checker_state.dart';
import '../bloc/skin_classifier_bloc/skin_classifier_bloc.dart';
import '../bloc/skin_classifier_bloc/skin_classifier_event.dart';
import '../bloc/skin_classifier_bloc/skin_classifier_state.dart';
import '../../domain/models/skin_request.dart';

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  final TextEditingController _symptomController = TextEditingController();
  bool _isInputValid = false;
  // If true, the Analyze action should classify an uploaded skin image instead
  // of analyzing textual symptoms. The app code can toggle this flag when
  // the user chooses 'Skin image' mode.
  bool isSkinImage = false;

  // The selected image file (e.g., from image_picker). If null, user hasn't
  // picked an image yet.
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _symptomController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isInputValid = _symptomController.text.trim().length >= 10;
    });
  }

  void _submitSymptoms() {
    if (!_isInputValid) return;

    context.read<SymptomCheckerBloc>().add(
      CheckSymptomsButtonPressed(_symptomController.text),
    );

    // Clear the input after submission
    _symptomController.clear();
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing symptoms...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<SymptomCheckerBloc, SymptomCheckerState>(
          listener: (context, state) {
            if (state is SymptomCheckerLoading) {
              _showLoadingDialog(context);
            } else if (state is SymptomCheckerSuccess ||
                state is SymptomCheckerFailure) {
              Navigator.of(context).pop(); // Dismiss loading dialog

              if (state is SymptomCheckerFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.error,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red.shade700,
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Dismiss',
                      textColor: Colors.white,
                      onPressed: () =>
                          ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    ),
                  ),
                );
              }
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Describe Your Symptoms'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Please describe your symptoms in detail:',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Separate multiple symptoms with new lines',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                    ),
                    child: TextField(
                      controller: _symptomController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText:
                            'Example:\nHeadache with moderate pain\nFever since yesterday\nDry cough',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (isSkinImage) {
                      if (_imageFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please pick an image first.'),
                          ),
                        );
                        return;
                      }

                      final request = SkinRequest(imageFile: _imageFile!);
                      context.read<SkinClassifierBloc>().add(
                        ClassifySkinImageEvent(request),
                      );
                    } else {
                      if (_isInputValid) {
                        _submitSymptoms();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isSkinImage ? 'Analyze Image' : 'Analyze Symptoms',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: (_isInputValid || isSkinImage)
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withOpacity(0.38),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Results view for skin classifier
                const SkinResultsView(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Describe Symptoms'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoPoint('Be specific about what you\'re experiencing'),
              _buildInfoPoint('Include when the symptoms started'),
              _buildInfoPoint('Mention if anything makes it better or worse'),
              _buildInfoPoint('Note any related symptoms'),
              _buildInfoPoint('Include the severity of your symptoms'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // end of _SymptomInputScreenState
}

/// A small results panel that listens to `SkinClassifierBloc` and renders
/// Loading / Failure / Success states. Place it where you want predictions to
/// appear (here it's placed under the Analyze button).
class SkinResultsView extends StatelessWidget {
  const SkinResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SkinClassifierBloc, SkinClassifierState>(
      builder: (context, state) {
        if (state is SkinClassifierLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SkinClassifierFailure) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                Text(state.error, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<SkinClassifierBloc>().add(
                    ResetSkinClassifierEvent(),
                  ),
                  child: const Text('Try again'),
                ),
              ],
            ),
          );
        }

        if (state is SkinClassifierSuccess) {
          final preds = state.predictions;
          if (preds.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No predictions returned.'),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: preds.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = preds[index];
              final confidencePercent = (p.confidence * 100).toStringAsFixed(1);
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(p.condition),
                subtitle: Text('$confidencePercent% confidence'),
                trailing: SizedBox(
                  width: 80,
                  child: LinearProgressIndicator(
                    value: p.confidence.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade200,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          );
        }

        // Initial state — render nothing (or a short hint)
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(''),
        );
      },
    );
  }
}
