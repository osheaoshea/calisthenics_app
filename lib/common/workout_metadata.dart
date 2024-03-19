import 'exercise_type.dart';

class WorkoutMetadata {
  final String id;
  final int repGoal;
  final ExerciseType type;

  WorkoutMetadata(this.id, this.repGoal, this.type);
}