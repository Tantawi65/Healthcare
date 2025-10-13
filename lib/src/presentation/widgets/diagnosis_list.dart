import 'package:flutter/material.dart';
import '../../domain/models/diagnosis.dart';

class DiagnosisList extends StatelessWidget {
  final List<Diagnosis> diagnoses;
  final Function(Diagnosis)? onDiagnosisTap;

  const DiagnosisList({
    super.key,
    required this.diagnoses,
    this.onDiagnosisTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: diagnoses.length,
      itemBuilder: (context, index) {
        final diagnosis = diagnoses[index];
        return _DiagnosisCard(
          diagnosis: diagnosis,
          onTap: () => onDiagnosisTap?.call(diagnosis),
          isFirst: index == 0,
        );
      },
    );
  }
}

class _DiagnosisCard extends StatelessWidget {
  final Diagnosis diagnosis;
  final VoidCallback? onTap;
  final bool isFirst;

  const _DiagnosisCard({
    super.key,
    required this.diagnosis,
    this.onTap,
    this.isFirst = false,
  });

  Color _getProbabilityColor(BuildContext context, double probability) {
    final theme = Theme.of(context);
    if (probability >= 0.7) {
      return Colors.red;
    } else if (probability >= 0.4) {
      return Colors.orange;
    }
    return theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final probabilityColor = _getProbabilityColor(
      context,
      diagnosis.probability,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: isFirst ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isFirst
              ? BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  width: 2,
                )
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diagnosis.condition,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: isFirst ? FontWeight.bold : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Probability: ${diagnosis.probabilityPercentage}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: probabilityColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: probabilityColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: diagnosis.probability,
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                probabilityColor,
                              ),
                            ),
                            Text(
                              diagnosis.probabilityPercentage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: probabilityColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (diagnosis.advice.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          diagnosis.advice,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (onTap != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: onTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Learn More',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
