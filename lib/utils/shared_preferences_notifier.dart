import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesNotifier {
  static final SharedPreferencesNotifier _instance = SharedPreferencesNotifier._internal();
  factory SharedPreferencesNotifier() => _instance;

  final StreamController<int> _streamController = StreamController<int>.broadcast();
  Stream<int> get stream => _streamController.stream;

  SharedPreferencesNotifier._internal();

  Future<void> incrementWorkoutCompletion(String workoutName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(workoutName) ?? 0;
    await prefs.setInt(workoutName, ++currentCount);
    _streamController.add(currentCount); // Notify listeners about the update
  }

  Future<void> resetAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _streamController.add(0); // Notify listeners about the update
  }

  void dispose() {
    _streamController.close();
  }
}
