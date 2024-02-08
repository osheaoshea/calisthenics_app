import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import '../utils/coordinates_translator.dart';


class PosePainter extends CustomPainter {

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  final Pose savedPose;
  final bool showFormCorrection;

  PosePainter(this.poses, this.imageSize, this.rotation,
      this.cameraLensDirection, this.savedPose, this.showFormCorrection);


  @override
  void paint(Canvas canvas, Size size) {

    final yellowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..color = Colors.yellow;

    final bluePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..color = Colors.blueAccent;

    final whitePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..color = Colors.white;

    final redPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..color = Colors.red;

    for (final pose in poses) {
      // paintPose(pose, canvas, size,
      //     yellowPaint, bluePaint, yellowPaint, bluePaint,
      //     whitePaint);
      paintPose(pose, canvas, size,
          whitePaint, whitePaint, whitePaint, whitePaint,
          whitePaint);
      if (showFormCorrection) {
        paintPose(savedPose, canvas, size,
            redPaint, redPaint, whitePaint, whitePaint,
            whitePaint);
      }
    }
  }

  void paintPose(Pose pose, Canvas canvas, Size size,
      Paint leftArmPaint, Paint rightArmPaint,
      Paint leftLegPaint, Paint rightLegPaint,
      Paint bodyPaint) {

    // create new landmarks
    PoseLandmark neck = PoseLandmark(
        type: PoseLandmarkType.nose,
        x: (pose.landmarks[PoseLandmarkType.leftShoulder]!.x + pose.landmarks[PoseLandmarkType.rightShoulder]!.x) / 2,
        y: (pose.landmarks[PoseLandmarkType.leftShoulder]!.y + pose.landmarks[PoseLandmarkType.rightShoulder]!.y) / 2,
        z: (pose.landmarks[PoseLandmarkType.leftShoulder]!.z + pose.landmarks[PoseLandmarkType.rightShoulder]!.z) / 2,
        likelihood: (pose.landmarks[PoseLandmarkType.leftShoulder]!.likelihood + pose.landmarks[PoseLandmarkType.rightShoulder]!.likelihood) / 2
    );

    PoseLandmark pelvis = PoseLandmark(
        type: PoseLandmarkType.nose,
        x: (pose.landmarks[PoseLandmarkType.leftHip]!.x + pose.landmarks[PoseLandmarkType.rightHip]!.x) / 2,
        y: (pose.landmarks[PoseLandmarkType.leftHip]!.y + pose.landmarks[PoseLandmarkType.rightHip]!.y) / 2,
        z: (pose.landmarks[PoseLandmarkType.leftHip]!.z + pose.landmarks[PoseLandmarkType.rightHip]!.z) / 2,
        likelihood: (pose.landmarks[PoseLandmarkType.leftHip]!.likelihood + pose.landmarks[PoseLandmarkType.rightHip]!.likelihood) / 2
    );

    void paintLine(
        PoseLandmark joint1, PoseLandmark joint2, Paint paintType
        ) {
      canvas.drawLine(
          Offset(
              translateX(
                joint1.x,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
              translateY(
                joint1.y,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              )),
          Offset(
              translateX(
                joint2.x,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
              translateY(
                joint2.y,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              )),
          paintType);
    }

    //Draw arms
    paintLine(
        neck,
        pose.landmarks[PoseLandmarkType.leftShoulder]!, leftArmPaint);
    paintLine(
        pose.landmarks[PoseLandmarkType.leftShoulder]!,
        pose.landmarks[PoseLandmarkType.leftElbow]!, leftArmPaint);
    paintLine(
        pose.landmarks[PoseLandmarkType.leftElbow]!,
        pose.landmarks[PoseLandmarkType.leftWrist]!, leftArmPaint);
    paintLine(
        neck,
        pose.landmarks[PoseLandmarkType.rightShoulder]!, rightArmPaint);
    paintLine(
        pose.landmarks[PoseLandmarkType.rightShoulder]!,
        pose.landmarks[PoseLandmarkType.rightElbow]!, rightArmPaint);
    paintLine(
        pose.landmarks[PoseLandmarkType.rightElbow]!,
        pose.landmarks[PoseLandmarkType.rightWrist]!, rightArmPaint);

    // Draw Body
    paintLine(neck, pelvis, bodyPaint);
    paintLine(
        neck, pose.landmarks[PoseLandmarkType.nose]!, bodyPaint);

    //Draw legs
    paintLine(
        pelvis,
        pose.landmarks[PoseLandmarkType.leftKnee]!, leftLegPaint);
    paintLine(
        pose.landmarks[PoseLandmarkType.leftKnee]!,
        pose.landmarks[PoseLandmarkType.leftAnkle]!, leftLegPaint);
    paintLine(
        pelvis,
        pose.landmarks[PoseLandmarkType.rightKnee]!, rightLegPaint);
    paintLine(
        pose.landmarks[PoseLandmarkType.rightKnee]!,
        pose.landmarks[PoseLandmarkType.rightAnkle]!, rightLegPaint);
  }



  // paint that shows the user a static pose of the position they should try and achieve

  // can get the length of their limbs from the pose estimation passed in
  // then write script that uses the hand as a start point
    // it builds the limbs (or next joint) from this point using the calculated limb lengths and provided angles

  // TODO - !!! possibly move this code to new class !!!

  /*

  Pose generateLowerArmsCorrection(Pose pose) {

    Map<String, (double, double)> bodyStructure = getLimbAngleAndLength(pose);

    // LEFT
    pose.landmarks[PoseLandmarkType.leftElbow] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.leftWrist]!,
        PoseLandmarkType.leftElbow,
        bodyStructure['leftForearm']!.$1,
        bodyStructure['leftForearm']!.$2);

    pose.landmarks[PoseLandmarkType.leftShoulder] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.leftElbow]!,
        PoseLandmarkType.leftShoulder,
        bodyStructure['leftBicep']!.$1,
        bodyStructure['leftBicep']!.$2 - toRadians(40));

    pose.landmarks[PoseLandmarkType.leftHip] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.leftShoulder]!,
        PoseLandmarkType.leftHip,
        bodyStructure['leftBody']!.$1,
        bodyStructure['leftBody']!.$2);

    pose.landmarks[PoseLandmarkType.leftKnee] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.leftHip]!,
        PoseLandmarkType.leftKnee,
        bodyStructure['leftQuad']!.$1,
        bodyStructure['leftQuad']!.$2);

    pose.landmarks[PoseLandmarkType.leftAnkle] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.leftKnee]!,
        PoseLandmarkType.leftAnkle,
        bodyStructure['leftCalf']!.$1,
        bodyStructure['leftCalf']!.$2);

    // RIGHT
    pose.landmarks[PoseLandmarkType.rightElbow] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.rightWrist]!,
        PoseLandmarkType.rightElbow,
        bodyStructure['rightForearm']!.$1,
        bodyStructure['rightForearm']!.$2);

    pose.landmarks[PoseLandmarkType.rightShoulder] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.rightElbow]!,
        PoseLandmarkType.rightShoulder,
        bodyStructure['rightBicep']!.$1,
        bodyStructure['rightBicep']!.$2 - toRadians(40));

    pose.landmarks[PoseLandmarkType.rightHip] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.rightShoulder]!,
        PoseLandmarkType.rightHip,
        bodyStructure['rightBody']!.$1,
        bodyStructure['rightBody']!.$2);

    pose.landmarks[PoseLandmarkType.rightKnee] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.rightHip]!,
        PoseLandmarkType.rightKnee,
        bodyStructure['rightQuad']!.$1,
        bodyStructure['rightQuad']!.$2);

    pose.landmarks[PoseLandmarkType.rightAnkle] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.rightKnee]!,
        PoseLandmarkType.rightAnkle,
        bodyStructure['rightCalf']!.$1,
        bodyStructure['rightCalf']!.$2);

    // NOSE
    pose.landmarks[PoseLandmarkType.nose] = findNewLandmark(
        pose.landmarks[PoseLandmarkType.leftShoulder]!,
        PoseLandmarkType.nose,
        bodyStructure['toNose']!.$1,
        bodyStructure['toNose']!.$2);

    return pose;
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


  */


  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }

}