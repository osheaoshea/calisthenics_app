import 'dart:math';

import 'package:calisthenics_app/pages/camera_view.dart';
import 'package:calisthenics_app/pages/painters/pose_painter.dart';
import 'package:calisthenics_app/pages/utils/form_correction_generator.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:audioplayers/audioplayers.dart';


// TODO - implement this as the 'press up' class & refactor

enum ExercisePhase {
  NA,
  TOP,
  DOWN,
  BOTTOM,
  UP
}

enum FormMistake {
  BOTTOM_ARMS,
  TOP_ARMS,
  HIGH_HIPS,
  LOW_HIPS,
  BENT_LEGS
}

class PoseSetupView extends StatefulWidget {
  const PoseSetupView({
    super.key,
    this.onCameraFeedReady,
    this.onCameraLensDirectionChanged,
  });

  final Function()? onCameraFeedReady;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;

  @override
  State<PoseSetupView> createState() => _PoseSetupViewState();
}

class _PoseSetupViewState extends State<PoseSetupView> {
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;

  CustomPaint? _customPaint;

  var _cameraLensDirection = CameraLensDirection.back;

  final PushUpAngles pushUpAngles = PushUpAngles();
  ExercisePhase phase = ExercisePhase.NA;
  int repCounter = 0; // TODO make rep counter own widget inside camera, then just pass the num value over

  // [top arms] [bottom arms] [rep counter] [text feedback]
  List<Widget?> _overlay = [Container(), Container(), Container(), Container()];

  bool showFormCorrection = false;
  // bool painterShowCorrection = false;
  Pose savedPose = Pose(landmarks: {});
  Pose bottomPosition = Pose(landmarks: {});
  Pose topPosition = Pose(landmarks: {});

  // form checking variables
  double maxArmAngle = -1.0;
  double minArmAngle = 181.0;

  // late final Function()? onCameraFeedReady;
  // late final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;

  @override
  void initState() {
    _overlay[2] = _generalOverlay(Colors.grey[800]!, repCounter.toString(), 40, 68+120);
    super.initState();
  }

  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      customPaint: _customPaint,
      overlay: _overlay,
      onImage: _processImage,
      onCameraFeedReady: widget.onCameraFeedReady,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    setState(() {});

    final poses = await _poseDetector.processImage(inputImage);

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {

      final painter = PosePainter(poses, inputImage.metadata!.size,
          inputImage.metadata!.rotation, _cameraLensDirection,
          savedPose, showFormCorrection);

      // possibly will have to normalise based on torso (?)
      // calculate angles over all joints (or specific ones for exercise)
      // if angles match start pos then begin 'counter'
      // if angles match end pos then increment 'counter'
      // -- how to deal with incorrect form --

      // TODO - form correction
        // when mistake is noticed, flag is set to trigger custom paint to load visuals
        // this also triggers an await timer function
          // this also sets a flag to prevent other displays of form correction
        // once time is up custom paint to removed & form-correction-visuals flag is allowed again

      for (Pose pose in poses) {

        double rightArmAngle = findAngle(
            pose.landmarks[PoseLandmarkType.rightWrist]!,
            pose.landmarks[PoseLandmarkType.rightElbow]!,
            pose.landmarks[PoseLandmarkType.rightShoulder]!);

        double leftArmAngle = findAngle(
            pose.landmarks[PoseLandmarkType.leftWrist]!,
            pose.landmarks[PoseLandmarkType.leftElbow]!,
            pose.landmarks[PoseLandmarkType.leftShoulder]!);

        double avgArmAngle = (rightArmAngle + leftArmAngle) / 2;

        // when going down update the minimum arm angle reached
        if (phase == ExercisePhase.DOWN) {
          if (avgArmAngle < minArmAngle) {
            minArmAngle = avgArmAngle;
            bottomPosition = pose;
          }
        }

        // when going up update the maximum arm angle reached
        if (phase == ExercisePhase.UP) {
          if (avgArmAngle > maxArmAngle) {
            maxArmAngle = avgArmAngle;
            topPosition = pose;
          }
        }

        // if in TOP position
        if (pushUpAngles.checkStartArmAngles(rightArmAngle, leftArmAngle)) {
          _overlay[0] = _generalOverlay(Colors.green, "Start Arms", 40, 68);

          if(phase == ExercisePhase.UP){
            // if we were in UP position, increment rep counter (i.e. one rep has been completed)
            repCounter++;
            _overlay[2] = _generalOverlay(Colors.grey[800]!, repCounter.toString(), 40, 68+120);
          } else if (phase == ExercisePhase.DOWN) {
            // if we were in DOWN position, never reached BOTTOM (i.e. didn't go low enough)
            // provide this feedback to user (with angles maybe)
            triggerFormCorrection(
                "FEEDBACK - did not go low enough (" + maxArmAngle.toString() + ")",
                FormMistake.BOTTOM_ARMS);
          }

          phase = ExercisePhase.TOP;
          minArmAngle = 181.0;
        } else {
          _overlay[0] = _generalOverlay(Colors.red, "Start Arms", 40, 68);
          // if we were in the top position but now aren't then we are going DOWN
          if (phase == ExercisePhase.TOP) {
            phase = ExercisePhase.DOWN;
          }
        }

        // if in BOTTOM position
        if (pushUpAngles.checkEndArmAngles(rightArmAngle, leftArmAngle)) {
          _overlay[1] = _generalOverlay(Colors.green, "End Arms", 40, 68+60);

          // if we were going UP and then got to BOTTOM again - we did not go high enough
          if (phase == ExercisePhase.UP) {
            // provide feedback
            triggerFormCorrection(
                "FEEDBACK - did not go high enough (" + maxArmAngle.toString() + ")",
                FormMistake.TOP_ARMS);
          }

          phase = ExercisePhase.BOTTOM;
          maxArmAngle = -1.0;
        } else {
          _overlay[1] = _generalOverlay(Colors.red, "End Arms", 40, 68+60);
          // if we were in the bottom position but now aren't - then we are going UP
          if (phase == ExercisePhase.BOTTOM) {
            phase = ExercisePhase.UP;
          }
        }

      }

      _customPaint = CustomPaint(
        painter: painter,
      );

    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  double findAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
    double radians = atan2(last.y - mid.y, last.x - mid.x) -
        atan2(first.y - mid.y, first.x - mid.x);

    double degrees = (radians * 180.0 / pi).abs();

    if (degrees > 180.0) {
      degrees = 360.0 - degrees;
    }

    return degrees;
  }

  void triggerFormCorrection(String debugText, FormMistake formMistake) {
    print(debugText);

    // if not already showing a form correction
    if (!showFormCorrection) {
      showFormCorrection = true;

      switch (formMistake) {
        case FormMistake.BOTTOM_ARMS:
          _overlay[3] = _textFeedback("Try and go lower next rep");
          savedPose = generateFormCorrection(bottomPosition, formMistake);
          AudioPlayer().play(AssetSource('audio/lowerArmsFormCorrection.mp3'));
        case FormMistake.TOP_ARMS:
          _overlay[3] = _textFeedback("Straighten arms at the top of each rep");
          savedPose = generateFormCorrection(topPosition, formMistake);
          AudioPlayer().play(AssetSource('audio/topArmsFormCorrection.mp3'));
        case FormMistake.HIGH_HIPS:
          // TODO: Handle this case.
        case FormMistake.LOW_HIPS:
          // TODO: Handle this case.
        case FormMistake.BENT_LEGS:
          // TODO: Handle this case.
      }

      // trigger timer
      Future.delayed(const Duration(seconds: 2), () {
        showFormCorrection = false;
        _overlay[3] = Container();
      });
    }
  }

  Widget _generalOverlay(Color _color, String _text, double _top, double _left) {
    return Positioned(
        top: _top,
        left: _left,
        child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: _color,
                border: Border.all(color: _color),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Center(
              child: Text(
                _text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                ),
              ),
            )));
  }

  Widget _textFeedback(String _feedback) {
    return Positioned(
        top: 40,
        right: 68,
        child: Container(
            width: 150,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.grey[800],
                border: Border.all(color: Colors.grey[800]!),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Center(
              child: Text( // TODO - possibly add padding
                _feedback,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            )));
  }
}

class PushUpAngles {
  final double startArmAngleMax = 181.0;
  final double startArmAngleMin = 180;//155.0;
  final double endArmAngleMax = 95.0;//30;//
  final double endArmAngleMin = 10;//10.0;

  PushUpAngles();

  bool checkStartArmAngles(right, left) {
    return right < startArmAngleMax &&
        right > startArmAngleMin &&
        left < startArmAngleMax &&
        left > startArmAngleMin;
  }

  bool checkEndArmAngles(right, left) {
    return right < endArmAngleMax &&
        right > endArmAngleMin &&
        left < endArmAngleMax &&
        left > endArmAngleMin;
  }

  // TODO - possibly check occlusion/likelihood (if < threshold, don't track that arm)
}