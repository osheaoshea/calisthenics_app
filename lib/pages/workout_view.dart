import 'dart:math';

import 'package:calisthenics_app/pages/camera_view.dart';
import 'package:calisthenics_app/painters/pose_painter.dart';
import 'package:calisthenics_app/utils/form_correction_generator.dart';
import 'package:calisthenics_app/common/form_mistake.dart';
import 'package:calisthenics_app/common/exercise_phase.dart';
import 'package:calisthenics_app/exercises/pushup_angles.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:audioplayers/audioplayers.dart';



class WorkoutView extends StatefulWidget {
  const WorkoutView({
    super.key,
    this.onCameraFeedReady,
    this.onCameraLensDirectionChanged,
  });

  final Function()? onCameraFeedReady;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;

  @override
  State<WorkoutView> createState() => _WorkoutViewState();
}

class _WorkoutViewState extends State<WorkoutView> {

  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;

  CustomPaint? _customPaint;

  var _cameraLensDirection = CameraLensDirection.back;

  final PushUpAngles pushUpAngles = PushUpAngles();

  ExercisePhase phase = ExercisePhase.NA;
  ExercisePhase prevPhase = ExercisePhase.NA;

  // used to delay form corrections
  int phaseCounter = 0; // track how long we have been in a given phase
  int phaseLimit = 3;
  int hipErrorCounter = 0;
  int hipErrorLimit = 6;
  int legErrorCounter = 0;
  int legErrorLimit = 6;

  int repCounter = 0; // TODO make rep counter own widget inside camera, then just pass the num value over
  int repGoal = 5;
  bool workoutComplete = false;

  // [0-text feedback] [1-rep counter] [2-timer] [3-end workout] [4-plank position] [5-debug]
  List<Widget?> _overlay = [Container(), Container(), Container(),
    Container(), Container(), Container()];

  // form correction variables
  bool showFormCorrection = false;
  FormMistake latestMistake = FormMistake.BENT_LEGS; // doesn't matter what it is initialised to
  Pose savedPose = Pose(landmarks: {});

  Pose bottomPosition = Pose(landmarks: {});
  Pose topPosition = Pose(landmarks: {});
  Pose hipPosition = Pose(landmarks: {});
  Pose legPosition = Pose(landmarks: {});

  // form angle variables
  double maxArmAngle = -1.0;
  double minArmAngle = 181.0;

  // plank variables
  // TODO more thoroughly test plank checker
  bool inPlank = false;
  int inPlankCounter = -5;
  double flatGrad = 0.8;


  @override
  void initState() {
    _overlay[1] = _repCounter(repCounter.toString());
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
      workoutComplete: workoutComplete,
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

    // finish workout when rep goal is met
    workoutComplete = repCounter >= repGoal;

    final poses = await _poseDetector.processImage(inputImage);

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {

      final painter = PosePainter(poses, inputImage.metadata!.size,
          inputImage.metadata!.rotation, _cameraLensDirection,
          savedPose, showFormCorrection, latestMistake);

      // update phase counter
      updatePhaseCounter();

      for (Pose pose in poses) {
        /** check in pushup plank position **/
        // TODO test in further detail & move to separate function
        // print(inPlank.toString() + " - " + inPlankCounter.toString()); // -- debug --
        if(!inPlankPosition(pose)){
          // if not in plant then
            // don't do any form correction
            // update overlay
          if (inPlankCounter > 5) {
            inPlank = false;
            inPlankCounter = 0;
            _overlay[4] = _textFeedback("Get into the plank pushup position");
            continue;
          } else if (inPlank) {
            inPlankCounter ++;
          } else {
            _overlay[4] = _textFeedback("Get into the plank pushup position");
            continue;
          }
        } else {
          if(inPlankCounter < 0) {
            inPlankCounter ++;
          } else {
            inPlank = true;
            inPlankCounter = 0;
            _overlay[4] = Container();
          }
        }

        /** checking hips **/
        checkHips(pose);

        /** checking legs **/
        checkLegs(pose);

        /** checking arms & increment reps **/
        checkArms(pose);
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

  void updatePhaseCounter() {
    if (phase == prevPhase) {
      phaseCounter ++;
    } else {
      phaseCounter = 0;
      prevPhase = phase;
    }
  }

  bool inPlankPosition(Pose pose) {
    PoseLandmark rightKnee = pose.landmarks[PoseLandmarkType.rightKnee]!;
    PoseLandmark rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;
    PoseLandmark rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder]!;

    double thighGrad = (rightKnee.x - rightHip.x) / (rightKnee.y - rightHip.y);
    double bodyGrad = (rightHip.x - rightShoulder.x) / (rightHip.y - rightShoulder.y);

    if((thighGrad > flatGrad && bodyGrad > flatGrad) ||
        (thighGrad < -flatGrad && bodyGrad < -flatGrad)) {
      return true;
    } else {
      return false;
    }
  }

  void checkHips(Pose pose) {
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
    // _overlay[5] = _generalOverlay(Colors.deepPurple, avgHipAngle.toStringAsFixed(1), 40, 68+180);

    // checking if hips are too high or too low
    if (!pushUpAngles.checkHipAngles(rightHipAngle, leftHipAngle)) {
      hipErrorCounter ++;
      if (hipErrorCounter > hipErrorLimit) {
        hipErrorCounter = 0;
        hipPosition = pose;
        triggerFormCorrection(
            "FEEDBACK - hips out of place (" + avgHipAngle.toString() + ")",
            FormMistake.LOW_HIPS);
      }
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
  }

  void checkLegs(Pose pose) {
    double rightLegAngle = findAngle(
        pose.landmarks[PoseLandmarkType.rightAnkle]!,
        pose.landmarks[PoseLandmarkType.rightKnee]!,
        pose.landmarks[PoseLandmarkType.rightHip]!, true);

    double leftLegAngle = findAngle(
        pose.landmarks[PoseLandmarkType.leftAnkle]!,
        pose.landmarks[PoseLandmarkType.leftKnee]!,
        pose.landmarks[PoseLandmarkType.leftHip]!, true);

    double avgLegAngle = (rightLegAngle + leftLegAngle) / 2;

    if(!pushUpAngles.checkLegAngles(rightLegAngle, leftLegAngle)) {
      legErrorCounter ++;
      if (legErrorCounter > legErrorLimit) {
        legErrorCounter = 0;
        legPosition = pose;
        triggerFormCorrection(
            "FEEDBACK - legs not straight (" + avgLegAngle.toString() + ")",
            FormMistake.BENT_LEGS);
      }
    }
  }

  void checkArms(Pose pose) {
    double rightArmAngle = findAngle(
        pose.landmarks[PoseLandmarkType.rightWrist]!,
        pose.landmarks[PoseLandmarkType.rightElbow]!,
        pose.landmarks[PoseLandmarkType.rightShoulder]!, false);

    double leftArmAngle = findAngle(
        pose.landmarks[PoseLandmarkType.leftWrist]!,
        pose.landmarks[PoseLandmarkType.leftElbow]!,
        pose.landmarks[PoseLandmarkType.leftShoulder]!, false);

    double avgArmAngle = (rightArmAngle + leftArmAngle) / 2;

    // when going down update the minimum arm angle reached & save pose
    if (phase == ExercisePhase.DOWN) {
      if (avgArmAngle < minArmAngle) {
        minArmAngle = avgArmAngle;
        bottomPosition = pose;
      }
    }

    // when going up update the maximum arm angle reached & save pose
    if (phase == ExercisePhase.UP) {
      if (avgArmAngle > maxArmAngle) {
        maxArmAngle = avgArmAngle;
        topPosition = pose;
      }
    }

    // if in TOP position
    if (pushUpAngles.checkStartArmAngles(rightArmAngle, leftArmAngle)) {

      if(phase == ExercisePhase.UP){
        // if we were in UP position, increment rep counter (i.e. one rep has been completed)
        repCounter++;
        _overlay[1] = _repCounter(repCounter.toString());
      } else if (phase == ExercisePhase.DOWN && phaseCounter > phaseLimit) {
        // if we were in DOWN position, never reached BOTTOM (i.e. didn't go low enough)
        // provide feedback
        triggerFormCorrection(
            "FEEDBACK - did not go low enough (" + maxArmAngle.toString() + ")",
            FormMistake.BOTTOM_ARMS);
      }

      phase = ExercisePhase.TOP;
      minArmAngle = 181.0;
    } else {
      // if we were in the top position but now aren't then we are going DOWN
      if (phase == ExercisePhase.TOP) {
        phase = ExercisePhase.DOWN;
      }
    }

    // if in BOTTOM position
    if (pushUpAngles.checkEndArmAngles(rightArmAngle, leftArmAngle)) {
      // if we were going UP and then got to BOTTOM again - we did not go high enough
      if (phase == ExercisePhase.UP && phaseCounter > phaseLimit) {
        // provide feedback
        triggerFormCorrection(
            "FEEDBACK - did not go high enough (" + maxArmAngle.toString() + ")",
            FormMistake.TOP_ARMS);
      }

      phase = ExercisePhase.BOTTOM;
      maxArmAngle = -1.0;
    } else {
      // if we were in the bottom position but now aren't - then we are going UP
      if (phase == ExercisePhase.BOTTOM) {
        phase = ExercisePhase.UP;
      }
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
          _overlay[0] = _textFeedback("Try and go lower next rep");
          savedPose = generateFormCorrection(bottomPosition, formMistake);
          AudioPlayer().play(AssetSource('audio/lowerArmsFormCorrection.mp3'));
        case FormMistake.TOP_ARMS:
          _overlay[0] = _textFeedback("Straighten arms at the top of each rep");
          savedPose = generateFormCorrection(topPosition, formMistake);
          AudioPlayer().play(AssetSource('audio/topArmsFormCorrection.mp3'));
        case FormMistake.HIGH_HIPS:
          // TODO clean up - not in use
          // _overlay[3] = _textFeedback("Try and lower your hips");
          // savedPose = generateFormCorrection(hipPosition, formMistake);
          // AudioPlayer().play(AssetSource('audio/highHipsFormCorrection.mp3'));
        case FormMistake.LOW_HIPS:
          _overlay[0] = _textFeedback("Straighten out your hips"); // old - Try bring your hips upwards
          savedPose = generateFormCorrection(hipPosition, formMistake);
          // need new audio for hips
          AudioPlayer().play(AssetSource('audio/lowHipsFormCorrection.mp3'));
        case FormMistake.BENT_LEGS:
          _overlay[0] = _textFeedback("Straighten out your legs");
          savedPose = generateFormCorrection(legPosition, formMistake);
          AudioPlayer().play(AssetSource('audio/bentLegsFormCorrection.mp3'));
      }

      // trigger timer
      Future.delayed(const Duration(seconds: 3), () {
        showFormCorrection = false;
        _overlay[0] = Container();
      });
    }
  }

  // -- used for debugging --
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

  Widget _repCounter(String _rep) {
    return Positioned(
        top: 40,
        right: 8,
        child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: Colors.grey[800]!,
                border: Border.all(color: Colors.grey[800]!),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _rep,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        letterSpacing: 1
                    ),
                  ),
                  Text(
                    "/$repGoal",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1
                    ),
                  ),
                ],
              ),
            )));
  }

  Widget _textFeedback(String _feedback) {
    return Positioned(
        top: 40,
        left: 68,
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
