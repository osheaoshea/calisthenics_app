import '../common/base_angles.dart';
import '../common/base_exercise.dart';
import '../exercises/pushup_angles.dart';

class Pushup extends BaseExercise {
  @override
  BaseAngles angles = PushupAngles();

  Pushup(super.repGoal);
}