import 'package:calisthenics_app/common/base_exercise.dart';
import 'package:calisthenics_app/common/exercise_type.dart';
import 'package:calisthenics_app/common/leg_check_return.dart';
import 'package:calisthenics_app/exercises/knee_pushup.dart';
import 'package:calisthenics_app/pages/camera_view.dart';
import 'package:calisthenics_app/painters/pose_painter.dart';
import 'package:calisthenics_app/utils/form_correction_generator.dart';
import 'package:calisthenics_app/common/form_mistake.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:audioplayers/audioplayers.dart';

import '../common/arm_check_return.dart';
import '../exercises/pushup.dart';


class WorkoutView extends StatefulWidget {
  const WorkoutView({
    super.key,
    required this.exerciseType,
    this.onCameraFeedReady,
    this.onCameraLensDirectionChanged,
  });

  final ExerciseType exerciseType;
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

  late BaseExercise exercise;
  bool debug_check = false;

  // TODO - move repGoal to some config
  int repGoal = 50;

  bool workoutComplete = false;

  // [0-text feedback] [1-rep counter] [2-timer] [3-end workout] [4-plank position] [5-debug]
  List<Widget?> _overlay = [Container(), Container(), Container(),
    Container(), Container(), Container()];

  // form correction variables
  bool showFormCorrection = false;
  FormMistake latestMistake = FormMistake.BENT_LEGS; // doesn't matter what it is initialised to
  Pose savedPose = Pose(landmarks: {});

  // TODO - sort plank functionality when adding in 'exercise setup pages' etc
  // plank variables
  bool inPlank = false;
  int inPlankCounter = -5;
  int plankErrorLimit = 5;
  double flatGrad = 0.8;


  @override
  void initState() {
    // load exercise
    switch(widget.exerciseType) {
      case ExerciseType.PUSHUP:
        exercise = Pushup(repGoal);
      case ExerciseType.KNEE_PUSHUP:
        exercise = KneePushup(repGoal);
    }

    _overlay[1] = _repCounter(exercise.repCounter.reps.toString());
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
    workoutComplete = exercise.repCounter.checkGoal();

    final poses = await _poseDetector.processImage(inputImage);

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {

      final painter = PosePainter(poses, inputImage.metadata!.size,
          inputImage.metadata!.rotation, _cameraLensDirection,
          savedPose, showFormCorrection, latestMistake);

      // update phase counter
      exercise.phaseTracker.updatePhaseCounter();

      for (Pose pose in poses) {

        // TODO - move these checks to separate class
        // TODO - (might have a base class that is overridden by specific exercises)
        /** check in pushup plank position **/
        bool skipChecks = !checkPlank(pose);

        // if not in plank position, skip the rest of the checks
        if (!skipChecks) {

          /** checking hips **/
          if(!exercise.checkHips(pose)) {
            // trigger form correction
            triggerFormCorrection("FEEDBACK - hips out of place",
                FormMistake.LOW_HIPS);
          }

          /** checking legs **/
          LegCheckReturn legCheckReturn = exercise.checkLegs(pose);
          switch(legCheckReturn) {
            case LegCheckReturn.FC_STRAIGHTEN_LEGS:
              // trigger form correction
              triggerFormCorrection("FEEDBACK - legs out of place",
                  FormMistake.BENT_LEGS);
            case LegCheckReturn.FC_BEND_LESS:
              // trigger form correction
              triggerFormCorrection("FEEDBACK - legs out of place",
                  FormMistake.BEND_LEGS_LESS);
            case LegCheckReturn.FC_BEND_MORE:
              // trigger form correction
              triggerFormCorrection("FEEDBACK - legs out of place",
                  FormMistake.BEND_LEGS_MORE);
            case LegCheckReturn.PASS:
              // no form correction needed
          }

          /** checking arms & increment reps **/
          ArmCheckReturn armCheckReturn = exercise.checkArms(pose);
          switch (armCheckReturn) {
            case ArmCheckReturn.UPDATE_REP:
              _overlay[1] = _repCounter(exercise.repCounter.reps.toString());
            case ArmCheckReturn.FC_BOTTOM_ARMS:
            // trigger form correction
              triggerFormCorrection("FEEDBACK - did not go low enough",
                  FormMistake.BOTTOM_ARMS);
            case ArmCheckReturn.FC_TOP_ARMS:
            // trigger form correction
              triggerFormCorrection("FEEDBACK - did not go high enough",
                  FormMistake.TOP_ARMS);
            case ArmCheckReturn.PASS:
            // no form correction needed
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

  bool checkPlank(Pose pose) {
    // Check if the user is in the plank position.
    if (inPlankPosition(pose)) {
      // If in plank and the counter is negative (initial buffer), increment towards 0.
      if (inPlankCounter < 0) {
        inPlankCounter++;
      } else {
        // User is in plank and has overcome the initial buffer or has returned to plank.
        inPlank = true;
        inPlankCounter = 0; // Reset counter as user is in correct position.
        _overlay[4] = Container(); // Clear feedback as user is in correct position.
      }
    } else {
      // Not in plank position, decrement or increment the counter based on the current state.
      if (inPlankCounter < plankErrorLimit) {
        // Increment the counter if it's less than 5 to avoid immediate feedback.
        inPlankCounter++;
      }

      // Provide feedback if not in plank position for more than 5 frames.
      if (inPlankCounter >= plankErrorLimit) {
        inPlank = false;
        _overlay[4] = _textFeedback("Get into the plank pushup position");
        return false; // Return false as the user is not in the correct position.
      }
    }

    return inPlank; // Return the current state of the inPlank flag.
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

  // TODO - move to separate class (NOT SURE HOW TO DO YET)
  void triggerFormCorrection(String debugText, FormMistake formMistake) {
    print(debugText);
    latestMistake = formMistake;

    // if not already showing a form correction
    if (!showFormCorrection) {
      showFormCorrection = true;

      switch (formMistake) {
        case FormMistake.BOTTOM_ARMS:
          _overlay[0] = _textFeedback("Try and go lower next rep");
          savedPose = generateFormCorrection(
              exercise.bottomPosition, formMistake, widget.exerciseType);
          AudioPlayer().play(AssetSource('audio/lowerArmsFormCorrection.mp3'));
        case FormMistake.TOP_ARMS:
          _overlay[0] = _textFeedback("Straighten arms at the top of each rep");
          savedPose = generateFormCorrection(
              exercise.topPosition, formMistake, widget.exerciseType);
          AudioPlayer().play(AssetSource('audio/topArmsFormCorrection.mp3'));
        case FormMistake.HIGH_HIPS:
        // TODO clean up - not in use
        // _overlay[3] = _textFeedback("Try and lower your hips");
        // savedPose = generateFormCorrection(hipPosition, formMistake);
        // AudioPlayer().play(AssetSource('audio/highHipsFormCorrection.mp3'));
        case FormMistake.LOW_HIPS:
          _overlay[0] = _textFeedback("Straighten out your hips"); // old - Try bring your hips upwards
          savedPose = generateFormCorrection(
              exercise.hipPosition, formMistake, widget.exerciseType);
          // need new audio for hips
          AudioPlayer().play(AssetSource('audio/lowHipsFormCorrection.mp3'));
        case FormMistake.BENT_LEGS:
          _overlay[0] = _textFeedback("Straighten out your legs");
          savedPose = generateFormCorrection(
              exercise.legPosition, formMistake, widget.exerciseType);
          AudioPlayer().play(AssetSource('audio/bentLegsFormCorrection.mp3'));
        case FormMistake.BEND_LEGS_LESS || FormMistake.BEND_LEGS_MORE:
          _overlay[0] = _textFeedback("Bend knees to 90 degrees");
          savedPose = generateFormCorrection(
              exercise.legPosition, formMistake, widget.exerciseType);
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
