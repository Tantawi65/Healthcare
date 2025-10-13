import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/symptom.dart';
import '../../domain/repositories/symptom_repository.dart';
import 'dart:convert';

class SymptomRepositoryImpl implements SymptomRepository {
  final SharedPreferences _prefs;
  static const String _symptomsKey = 'user_symptoms';

  SymptomRepositoryImpl(this._prefs);

  @override
  Future<List<Symptom>> getAvailableSymptoms() async {
    // In a real application, this would come from an API
    return [
      Symptom(
        id: '1',
        name: 'Headache',
        description: 'Pain in the head or upper neck',
        category: 'Neurological',
      ),
      Symptom(
        id: '2',
        name: 'Fever',
        description: 'Elevated body temperature',
        category: 'General',
      ),
      Symptom(
        id: '3',
        name: 'Cough',
        description: 'Sudden expulsion of air',
        category: 'Respiratory',
      ),
      // Add more symptoms as needed
    ];
  }

  @override
  Future<Map<String, double>> analyzeSymptoms(List<Symptom> symptoms) async {
    // In a real application, this would use an AI model or API
    // This is a simplified example
    return {
      'Common Cold': 0.7,
      'Flu': 0.5,
      'Allergies': 0.3,
    };
  }

  @override
  Future<void> saveUserSymptoms(List<Symptom> symptoms) async {
    final symptomsJson = symptoms
        .map((symptom) => jsonEncode(symptom.toJson()))
        .toList();
    await _prefs.setStringList(_symptomsKey, symptomsJson);
  }

  @override
  Future<List<Symptom>> getUserSymptomHistory() async {
    final symptomsJson = _prefs.getStringList(_symptomsKey) ?? [];
    return symptomsJson
        .map((json) => Symptom.fromJson(jsonDecode(json)))
        .toList();
  }
}