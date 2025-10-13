class Diagnosis {
  final String condition;
  final double probability;
  final String advice;

  const Diagnosis({
    required this.condition,
    required this.probability,
    required this.advice,
  });

  // Convert probability to percentage string
  String get probabilityPercentage => '${(probability * 100).toStringAsFixed(1)}%';
}