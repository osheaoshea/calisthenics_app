
import 'package:calisthenics_app/common/form_mistake.dart';
import 'package:calisthenics_app/utils/coordinates_translator.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';


class PosePainter extends CustomPainter {

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  final Pose savedPose;
  final bool showFormCorrection;
  final FormMistake mistake;

  PosePainter(this.poses, this.imageSize, this.rotation,
      this.cameraLensDirection, this.savedPose, this.showFormCorrection,
      this.mistake);


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

    final greenPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..color = Colors.green;

    for (final pose in poses) {
      // paintPose(pose, canvas, size,
      //     yellowPaint, bluePaint, yellowPaint, bluePaint,
      //     whitePaint);
      paintPose(pose, canvas, size,
          whitePaint, whitePaint, whitePaint, whitePaint,
          whitePaint);
      if (showFormCorrection) {
        if (mistake == FormMistake.TOP_ARMS || mistake == FormMistake.BOTTOM_ARMS) {
          paintPose(savedPose, canvas, size,
              greenPaint, greenPaint, whitePaint, whitePaint,
              whitePaint);
        } else if (mistake == FormMistake.LOW_HIPS || mistake == FormMistake.HIGH_HIPS) {
          paintPose(savedPose, canvas, size,
              whitePaint, whitePaint, whitePaint, whitePaint,
              greenPaint);
        } else if (mistake == FormMistake.BENT_LEGS || mistake == FormMistake.BEND_LEGS_MORE
            || mistake == FormMistake.BEND_LEGS_LESS) {
          paintPose(savedPose, canvas, size,
              whitePaint, whitePaint, greenPaint, greenPaint,
              whitePaint);
        }
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

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }

}