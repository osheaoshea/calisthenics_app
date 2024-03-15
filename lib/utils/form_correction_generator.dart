import 'dart:math';

import 'package:calisthenics_app/common/base_FC_poses.dart';
import 'package:calisthenics_app/common/exercise_type.dart';
import 'package:calisthenics_app/common/form_mistake.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'FC_pose_factory.dart';


Pose generateFormCorrection(Pose pose, FormMistake formMistake, ExerciseType exerciseType){

  Map<String, (double, double)> bodyStructure = getLimbAngleAndLength(pose);

  Map<String, (double, double)> correction;

  bool invert = pose.landmarks[PoseLandmarkType.leftShoulder]!.x >
      pose.landmarks[PoseLandmarkType.leftHip]!.x;

  BaseFCPoses FCPoses = FCPoseFactory.getFCPoses(exerciseType);

  switch (formMistake) {
    case FormMistake.BOTTOM_ARMS:
      correction = Map.from(FCPoses.bottomArms);
      if (invert) {
        correction.updateAll((key, value) => (value.$1, -value.$2));
      }
    case FormMistake.TOP_ARMS:
      correction = Map.from(FCPoses.topArms);
    case FormMistake.HIGH_HIPS:
      correction = Map.from(FCPoses.highHips);
      invert ? invertAngles(correction) : null;
    case FormMistake.LOW_HIPS:
      correction = Map.from(FCPoses.lowHips);
      invert ? invertAngles(correction) : null;
    case FormMistake.BENT_LEGS:
      correction = Map.from(FCPoses.bentLegs);
      invert ? invertAngles(correction) : null;
    case FormMistake.BEND_LEGS_MORE || FormMistake.BEND_LEGS_LESS:
      correction = Map.from(FCPoses.bentLegs);
      invert ? invertAngles(correction) : null;
    case FormMistake.NONE:
      return pose;
  }

  // LEFT
  pose.landmarks[PoseLandmarkType.leftElbow] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.leftWrist]!,
      PoseLandmarkType.leftElbow,
      bodyStructure['leftForearm']!.$1,
      (bodyStructure['leftForearm']!.$2 *
          correction['leftForearm']!.$1) +
          toRadians(correction['leftForearm']!.$2));

  pose.landmarks[PoseLandmarkType.leftShoulder] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.leftElbow]!,
      PoseLandmarkType.leftShoulder,
      bodyStructure['leftBicep']!.$1,
      (bodyStructure['leftBicep']!.$2 *
          correction['leftBicep']!.$1) +
          toRadians(correction['leftBicep']!.$2));// - toRadians(40));

  pose.landmarks[PoseLandmarkType.leftHip] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.leftShoulder]!,
      PoseLandmarkType.leftHip,
      bodyStructure['leftBody']!.$1,
      (bodyStructure['leftBody']!.$2 *
          correction['leftBody']!.$1) +
          toRadians(correction['leftBody']!.$2));

  pose.landmarks[PoseLandmarkType.leftKnee] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.leftHip]!,
      PoseLandmarkType.leftKnee,
      bodyStructure['leftQuad']!.$1,
      (bodyStructure['leftQuad']!.$2 *
          correction['leftQuad']!.$1) +
          toRadians(correction['leftQuad']!.$2));

  pose.landmarks[PoseLandmarkType.leftAnkle] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.leftKnee]!,
      PoseLandmarkType.leftAnkle,
      bodyStructure['leftCalf']!.$1,
      (bodyStructure['leftCalf']!.$2 *
          correction['leftCalf']!.$1) +
          toRadians(correction['leftCalf']!.$2));

  // RIGHT
  pose.landmarks[PoseLandmarkType.rightElbow] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.rightWrist]!,
      PoseLandmarkType.rightElbow,
      bodyStructure['rightForearm']!.$1,
      (bodyStructure['rightForearm']!.$2 *
          correction['rightForearm']!.$1) +
          toRadians(correction['rightForearm']!.$2));

  pose.landmarks[PoseLandmarkType.rightShoulder] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.rightElbow]!,
      PoseLandmarkType.rightShoulder,
      bodyStructure['rightBicep']!.$1,
      (bodyStructure['rightBicep']!.$2 *
          correction['rightBicep']!.$1) +
          toRadians(correction['rightBicep']!.$2));// - toRadians(40));

  pose.landmarks[PoseLandmarkType.rightHip] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.rightShoulder]!,
      PoseLandmarkType.rightHip,
      bodyStructure['rightBody']!.$1,
      (bodyStructure['rightBody']!.$2 *
          correction['rightBody']!.$1) +
          toRadians(correction['rightBody']!.$2));

  pose.landmarks[PoseLandmarkType.rightKnee] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.rightHip]!,
      PoseLandmarkType.rightKnee,
      bodyStructure['rightQuad']!.$1,
      (bodyStructure['rightQuad']!.$2 *
          correction['rightQuad']!.$1) +
          toRadians(correction['rightQuad']!.$2));

  pose.landmarks[PoseLandmarkType.rightAnkle] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.rightKnee]!,
      PoseLandmarkType.rightAnkle,
      bodyStructure['rightCalf']!.$1,
      (bodyStructure['rightCalf']!.$2 *
          correction['rightCalf']!.$1) +
          toRadians(correction['rightCalf']!.$2));

  // NOSE
  pose.landmarks[PoseLandmarkType.nose] = findNewLandmark(
      pose.landmarks[PoseLandmarkType.leftShoulder]!,
      PoseLandmarkType.nose,
      bodyStructure['toNose']!.$1,
      (bodyStructure['toNose']!.$2 *
          correction['toNose']!.$1) +
          toRadians(correction['toNose']!.$2));

  return pose;
}

void invertAngles(Map<String, (double, double)> correction) {
  correction.updateAll((key, value) => value.$1 == 0
      ? (value.$1, reflectAngleAboutYAxis(value.$2))
      : value
  );
}

// reflect angle about the visual Y axis on the screen
double reflectAngleAboutYAxis(double x) {
  double translate = x - 90;
  double reflect = 360 - translate;
  return (reflect + 90) % 360;
}

PoseLandmark findNewLandmark(PoseLandmark a, PoseLandmarkType type, double dist, double angle) {
  angle += pi; // rotate the angle
  return PoseLandmark(type: type,
      x: a.x + dist * cos(angle),
      y: a.y + dist * sin(angle),
      z: a.z,
      likelihood: 1.0);
}

Map<String, (double, double)> getLimbAngleAndLength(Pose pose) {
  Map<String, (double, double)> result = {
    'leftForearm': getAngleAndLength(pose.landmarks[PoseLandmarkType.leftWrist]!,
        pose.landmarks[PoseLandmarkType.leftElbow]!),
    'leftBicep': getAngleAndLength(pose.landmarks[PoseLandmarkType.leftElbow]!,
        pose.landmarks[PoseLandmarkType.leftShoulder]!),
    'leftBody': getAngleAndLength(pose.landmarks[PoseLandmarkType.leftShoulder]!,
        pose.landmarks[PoseLandmarkType.leftHip]!),
    'leftQuad': getAngleAndLength(pose.landmarks[PoseLandmarkType.leftHip]!,
        pose.landmarks[PoseLandmarkType.leftKnee]!),
    'leftCalf': getAngleAndLength(pose.landmarks[PoseLandmarkType.leftKnee]!,
        pose.landmarks[PoseLandmarkType.leftAnkle]!),

    'rightForearm': getAngleAndLength(pose.landmarks[PoseLandmarkType.rightWrist]!,
        pose.landmarks[PoseLandmarkType.rightElbow]!),
    'rightBicep': getAngleAndLength(pose.landmarks[PoseLandmarkType.rightElbow]!,
        pose.landmarks[PoseLandmarkType.rightShoulder]!),
    'rightBody': getAngleAndLength(pose.landmarks[PoseLandmarkType.rightShoulder]!,
        pose.landmarks[PoseLandmarkType.rightHip]!),
    'rightQuad': getAngleAndLength(pose.landmarks[PoseLandmarkType.rightHip]!,
        pose.landmarks[PoseLandmarkType.rightKnee]!),
    'rightCalf': getAngleAndLength(pose.landmarks[PoseLandmarkType.rightKnee]!,
        pose.landmarks[PoseLandmarkType.rightAnkle]!),

    'toNose': getAngleAndLength(pose.landmarks[PoseLandmarkType.leftShoulder]!,
        pose.landmarks[PoseLandmarkType.nose]!),
  };
  return result;
}

(double, double) getAngleAndLength(PoseLandmark a, PoseLandmark b) {
  return (
  sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2)),
  atan2((a.y - b.y), (a.x - b.x))
  );
}

double toRadians(double x) {
  return (x * pi)/180;
}