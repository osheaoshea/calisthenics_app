import 'package:calisthenics_app/common/exercise_type.dart';
import 'package:calisthenics_app/common/form_mistake.dart';
import 'package:intl/intl.dart';

class StatTracker {
  int completedReps = 0;
  late int goalReps;

  late ExerciseType exerciseType;

  String completionTime = 'ERROR - no time';
  String completionDate = 'ERROR - no date';

  Map<FormMistake, int> mistakeCounter = {
    FormMistake.BOTTOM_ARMS: 0,
    FormMistake.TOP_ARMS: 0,
    FormMistake.LOW_HIPS: 0,
    FormMistake.HIGH_HIPS: 0,
    FormMistake.BENT_LEGS: 0,
    FormMistake.BEND_LEGS_MORE: 0,
    FormMistake.BEND_LEGS_LESS: 0,
  };

  StatTracker(int _goalReps, ExerciseType _type){
    goalReps = _goalReps;
    exerciseType = _type;
  }

  void increment(FormMistake formMistake) {
    mistakeCounter[formMistake] = mistakeCounter[formMistake]! + 1;
  }

  void setCompletionDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formatted = formatter.format(now);
    completionDate = formatted;
  }
}