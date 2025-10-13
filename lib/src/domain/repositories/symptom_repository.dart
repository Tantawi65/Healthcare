import '../models/symptom.dart';

abstract class SymptomRepository {
  Future<List<Symptom>> getAvailableSymptoms();
  Future<Map<String, double>> analyzeSymptoms(List<Symptom> symptoms);
  Future<void> saveUserSymptoms(List<Symptom> symptoms);
  Future<List<Symptom>> getUserSymptomHistory();
}