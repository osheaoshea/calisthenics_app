// base class for exercise functionality
// common vars & methods for all exercises
import 'package:calisthenics_app/common/arm_check_return.dart';
import 'package:calisthenics_app/common/base_angles.dart';
import 'package:calisthenics_app/common/leg_check_return.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../utils/find_angle.dart';
import '../utils/phase_tracker.dart';
import '../utils/rep_counter.dart';
import 'exercise_phase.dart';

class BaseExercise {
  late PhaseTracker phaseTracker;
  late RepCounter repCounter;

  // limits for delaying feedback
  int phaseLimit = 5; // 3 -> 5
  int hipErrorCounter = 0;
  int hipErrorLimit = 6;
  int legErrorCounter = 0;
  int legErrorLimit = 6;

  // form pose variables
  Pose bottomPosition = Pose(landmarks: {});
  Pose topPosition = Pose(landmarks: {});
  Pose hipPosition = Pose(landmarks: {});
  Pose legPosition = Pose(landmarks: {});

  late BaseAngles angles;

  // form angle variables
  double maxArmAngle = -1.0;
  double minArmAngle = 361.0; //181.0;

  BaseExercise(int repGoal) {
    phaseTracker = PhaseTracker(phaseLimit);
    repCounter = RepCounter(repGoal);
  }

  bool checkHips(Pose pose) {
    bool output = true;

    double rightHipAngle = findAngle(
        pose.landmarks[PoseLandmarkType.rightKnee]!,
        pose.landmarks[PoseLandmarkType.rightHip]!,
        pose.landmarks[PoseLandmarkType.rightShoulder]!);

    double leftHipAngle = findAngle(
        pose.landmarks[PoseLandmarkType.leftKnee]!,
        pose.landmarks[PoseLandmarkType.leftHip]!,
        pose.landmarks[PoseLandmarkType.leftShoulder]!);

    // checking if hips are too high or too low
    if (!angles.checkHipAngles(rightHipAngle, leftHipAngle)) {
      hipErrorCounter ++;
      // TODO - future work - fix high hips error
      if (hipErrorCounter > hipErrorLimit) {
        hipErrorCounter = 0;
        hipPosition = pose;
        output = false;
      }
    }

    return output;
  }

  LegCheckReturn checkLegs(Pose pose) {
    LegCheckReturn output = LegCheckReturn.PASS;

    double rightLegAngle = findAngle(
        pose.landmarks[PoseLandmarkType.rightAnkle]!,
        pose.landmarks[PoseLandmarkType.rightKnee]!,
        pose.landmarks[PoseLandmarkType.rightHip]!);

    double leftLegAngle = findAngle(
        pose.landmarks[PoseLandmarkType.leftAnkle]!,
        pose.landmarks[PoseLandmarkType.leftKnee]!,
        pose.landmarks[PoseLandmarkType.leftHip]!);

    if(!angles.checkLegAngles(rightLegAngle, leftLegAngle)) {
      legErrorCounter ++;
      if (legErrorCounter > legErrorLimit) {
        legErrorCounter = 0;
        legPosition = pose;
        output = LegCheckReturn.FC_STRAIGHTEN_LEGS;
      }
    }

    return output;
  }

  ArmCheckReturn checkArms(Pose pose) {
    ArmCheckReturn output = ArmCheckReturn.PASS;

    double rightArmAngle = findAngle(
        pose.landmarks[PoseLandmarkType.rightWrist]!,
        pose.landmarks[PoseLandmarkType.rightElbow]!,
        pose.landmarks[PoseLandmarkType.rightShoulder]!);

    double leftArmAngle = findAngle(
        pose.landmarks[PoseLandmarkType.leftWrist]!,
        pose.landmarks[PoseLandmarkType.leftElbow]!,
        pose.landmarks[PoseLandmarkType.leftShoulder]!);

    double avgArmAngle = (rightArmAngle + leftArmAngle) / 2;

    // when going down update the minimum arm angle reached & save pose
    if (phaseTracker.ifDownPhase()) {
      if (avgArmAngle < minArmAngle) {
        minArmAngle = avgArmAngle;
        bottomPosition = pose;
      }
    }

    // when going up update the maximum arm angle reached & save pose
    if (phaseTracker.ifUpPhase()) {
      if (avgArmAngle > maxArmAngle) {
        maxArmAngle = avgArmAngle;
        topPosition = pose;
      }
    }

    // if in TOP position
    if (angles.checkStartArmAngles(rightArmAngle, leftArmAngle)) {

      if(phaseTracker.ifUpPhase()){
        // if we were in UP position, increment rep counter (i.e. one rep has been completed)
        repCounter.increment();
        output = ArmCheckReturn.UPDATE_REP;
      } else if (phaseTracker.checkLimitDown()) {
        // if we were in DOWN position, never reached BOTTOM (i.e. didn't go low enough)
        // provide feedback
        output = ArmCheckReturn.FC_BOTTOM_ARMS;
      }

      phaseTracker.setPhase(ExercisePhase.TOP);
      minArmAngle = 181.0;
    } else {
      // if we were in the top position but now aren't then we are going DOWN
      if (phaseTracker.ifTopPhase()) {
        phaseTracker.setPhase(ExercisePhase.DOWN);
      }
    }

    // if in BOTTOM position
    if (angles.checkEndArmAngles(rightArmAngle, leftArmAngle)) {
      // if we were going UP and then got to BOTTOM again - we did not go high enough
      if (phaseTracker.checkLimitUp()) {
        // provide feedback
        output = ArmCheckReturn.FC_TOP_ARMS;
      }

      phaseTracker.setPhase(ExercisePhase.BOTTOM);
      maxArmAngle = -1.0;
    } else {
      // if we were in the bottom position but now aren't - then we are going UP
      if (phaseTracker.ifBottomPhase()) {
        phaseTracker.setPhase(ExercisePhase.UP);
      }
    }

    return output;
  }

}