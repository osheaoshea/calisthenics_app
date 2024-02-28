/*
import 'dart:math';

import 'package:calisthenics_app/pages/camera_view.dart';
import 'package:calisthenics_app/painters/pose_painter.dart';
import 'package:calisthenics_app/utils/form_correction_generator.dart';
import 'package:calisthenics_app/common/form_mistake.dart';
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
  ExercisePhase prevPhase = ExercisePhase.NA;
  int repCounter = 0; // TODO make rep counter own widget inside camera, then just pass the num value over
  int phaseCounter = 0; // track how long we have been in a given phase

  // [top arms] [bottom arms] [rep counter] [text feedback] [angle debug] [angle debug]
  List<Widget?> _overlay = [Container(), Container(), Container(), Container(),
    Container(), Container()];

  // form correction variables
  bool showFormCorrection = false;
  FormMistake latestMistake = FormMistake.BENT_LEGS; // doesn't matter what it is initialised to
  Pose savedPose = Pose(landmarks: {});
  Pose bottomPosition = Pose(landmarks: {});
  Pose topPosition = Pose(landmarks: {});
  Pose hipPosition = Pose(landmarks: {});

  // form angle variables
  double maxArmAngle = -1.0;
  double minArmAngle = 181.0;


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
      workoutComplete: false,
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
          savedPose, showFormCorrection, latestMistake);

      // update phase counter
      if (phase == prevPhase) {
        phaseCounter ++;
      } else {
        phaseCounter = 0;
        prevPhase = phase;
      }

      for (Pose pose in poses) {
        // print(phase.toString() + " - " + phaseCounter.toString());

        /** checking hips **/
        double rightHipAngle = findAngle(
            pose.landmarks[PoseLandmarkType.rightKnee]!,
            pose.landmarks[PoseLandmarkType.rightHip]!,
            pose.landmarks[PoseLandmarkType.rightShoulder]!, true);

        double leftHipAngle = findAngle(
            pose.landmarks[PoseLandmarkType.leftKnee]!,
            pose.landmarks[PoseLandmarkType.leftHip]!,
            pose.landmarks[PoseLandmarkType.leftShoulder]!, true);

        double avgHipAngle = (rightHipAngle + leftHipAngle) / 2;

        // -- DEBUG --
        // print(rightHipAngle.toString() + " | " + leftHipAngle.toString());
        // print(avgHipAngle);
        _overlay[4] = _generalOverlay(Colors.deepPurple, avgHipAngle.toStringAsFixed(1), 40, 68+180);

        // checking if hips are too high or too low
        if (!pushUpAngles.checkHipAngles(rightHipAngle, leftHipAngle)) {
          hipPosition = pose;
          triggerFormCorrection(
                "FEEDBACK - hips out of place (" + avgHipAngle.toString() + ")",
                FormMistake.LOW_HIPS);
          /*
          // if too low
          if (avgHipAngle > pushUpAngles.hipAngleMax) {
            triggerFormCorrection(
                "FEEDBACK - hips too low (" + avgHipAngle.toString() + ")",
                FormMistake.LOW_HIPS);
          } else if (avgHipAngle < pushUpAngles.hipAngleMin) {
            triggerFormCorrection(
                "FEEDBACK - hips too high (" + avgHipAngle.toString() + ")",
                FormMistake.HIGH_HIPS);
          }
           */
        }

        /** checking legs **/
        // ankle-knee-hip - close to 180


        /** checking arms **/
        double rightArmAngle = findAngle(
            pose.landmarks[PoseLandmarkType.rightWrist]!,
            pose.landmarks[PoseLandmarkType.rightElbow]!,
            pose.landmarks[PoseLandmarkType.rightShoulder]!, false);

        double leftArmAngle = findAngle(
            pose.landmarks[PoseLandmarkType.leftWrist]!,
            pose.landmarks[PoseLandmarkType.leftElbow]!,
            pose.landmarks[PoseLandmarkType.leftShoulder]!, false);

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
          } else if (phase == ExercisePhase.DOWN && phaseCounter > 2) {
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
          // TODO - bug - form correction triggered at bottom of rep before even reached top
          /// observed that when reach bottom the occluded arm sometimes spazams to 180 degrees
          /// this means when in the BOTTOM position it thinks its in the UP position for a split second
          /// consistently only one UP then back to DOWN pos
          /// could track how many UPs we have and only after a certain threshold the form correction can be triggered
          if (phase == ExercisePhase.UP && phaseCounter > 2) {
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

  double findAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last, bool hipFlag) {
    double radians = atan2(last.y - mid.y, last.x - mid.x) -
        atan2(first.y - mid.y, first.x - mid.x);

    double degrees = (radians * 180.0 / pi).abs();

    if (degrees > 180.0) {
      degrees = 360.0 - degrees;
    }

    // -- hip debugging --
    /*
    if (hipFlag) {
      double quadGrad = (mid.x - first.x) / (mid.y - first.y);
      double bodyGrad = (last.x - mid.x) / (last.y - mid.y);
      String test;
      if(quadGrad > bodyGrad){
        test = "QUAD";
      } else {
        test = "BODY";
      }

      // find orientation
      if(first.x > mid.x) {
        print("A - " + test + " - " + quadGrad.toString() + " | " + bodyGrad.toString());
      } else {
        print("B - " + test + " - " + quadGrad.toString() + " | " + bodyGrad.toString());
      }

      // check the gradient of first - mid
      // check gradient of mid - last
      // if A is

      // TODO - note - might be able to do something with angles instead of calculating gradients
      /// check angles form the form correction painting
    }

     */

    return degrees;
  }

  void triggerFormCorrection(String debugText, FormMistake formMistake) {
    print(debugText);
    latestMistake = formMistake;

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
          // not in use
          // _overlay[3] = _textFeedback("Try and lower your hips");
          // savedPose = generateFormCorrection(hipPosition, formMistake);
          // AudioPlayer().play(AssetSource('audio/highHipsFormCorrection.mp3'));
        case FormMistake.LOW_HIPS:
          _overlay[3] = _textFeedback("Straighten out your hips"); // old - Try bring your hips upwards
          savedPose = generateFormCorrection(hipPosition, formMistake);
          // need new audio for hips
          // AudioPlayer().play(AssetSource('audio/lowHipsFormCorrection.mp3'));
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
  final double startArmAngleMin = 155.0;//180;//
  final double endArmAngleMax = 95.0;//30;//
  final double endArmAngleMin = 10;
  final double hipAngleMax = 190;
  final double hipAngleMin = 150;

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

  bool checkHipAngles(right, left) {
    return right < hipAngleMax &&
        right > hipAngleMin &&
        left < hipAngleMax &&
        left > hipAngleMin;
  }

  // TODO - possibly check occlusion/likelihood (if < threshold, don't track that arm)
}

 */