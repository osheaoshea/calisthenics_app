import 'package:calisthenics_app/common/base_FC_poses.dart';
import 'package:calisthenics_app/common/exercise_type.dart';
import 'package:calisthenics_app/exercises/knee_pushup_FC_poses.dart';
import 'package:calisthenics_app/exercises/pushup_FC_poses.dart';

class FCPoseFactory {
  static BaseFCPoses getFCPoses(ExerciseType exerciseType) {
    switch (exerciseType) {
      case ExerciseType.PUSHUP:
        return PushupFCPoses();
      case ExerciseType.KNEE_PUSHUP:
        return KneePushupFCPoses();
    }
  }
}