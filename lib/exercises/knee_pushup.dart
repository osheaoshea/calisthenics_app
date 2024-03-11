import 'package:calisthenics_app/common/leg_check_return.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../common/base_angles.dart';
import '../common/base_exercise.dart';
import '../exercises/knee_pushup_angles.dart';
import '../utils/find_angle.dart';

class KneePushup extends BaseExercise {
  @override
  BaseAngles angles = KneePushupAngles();

  int legHighErrorCounter = 0;
  int legLowErrorCounter = 0;

  KneePushup(super.repGoal);

  @override
  LegCheckReturn checkLegs(Pose pose) {
    double rightLegAngle = findAngle(
        pose.landmarks[PoseLandmarkType.rightAnkle]!,
        pose.landmarks[PoseLandmarkType.rightKnee]!,
        pose.landmarks[PoseLandmarkType.rightHip]!);

    double leftLegAngle = findAngle(
        pose.landmarks[PoseLandmarkType.leftAnkle]!,
        pose.landmarks[PoseLandmarkType.leftKnee]!,
        pose.landmarks[PoseLandmarkType.leftHip]!);

    double avgLegAngle = (rightLegAngle + leftLegAngle) / 2;
    // _overlay[5] = _generalOverlay(Colors.deepPurple, avgLegAngle.toStringAsFixed(1), 40, 300);

    int legError = angles.checkKneeAngles(rightLegAngle, leftLegAngle);

    switch (legError) {
      case 1:
      // if legs too high
        legHighErrorCounter ++;
        if (legHighErrorCounter > legErrorLimit) {
          legHighErrorCounter = 0;
          legPosition = pose;
          return LegCheckReturn.FC_BEND_LESS;
        }
      case 2:
      // if legs too low
        legLowErrorCounter ++;
        if (legLowErrorCounter > legErrorLimit) {
          legLowErrorCounter = 0;
          legPosition = pose;
          return LegCheckReturn.FC_BEND_MORE;
        }
    }

    return LegCheckReturn.PASS;
  }
}