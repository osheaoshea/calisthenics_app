import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraView extends StatefulWidget {
  CameraView(
      {Key? key,
      required this.customPaint,
      required this.overlay,
      required this.onImage,
      this.onCameraFeedReady,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.back,
      required this.workoutComplete})
      : super(key: key);

  final CustomPaint? customPaint;
  final List<Widget?> overlay;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;
  final bool workoutComplete;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  // define vars
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  bool _changingCameraLens = false;

  Stopwatch stopwatch = Stopwatch();

  bool oneTimeRedirectFlag = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    stopwatch.start();

    // end workout after given time
    Timer(Duration(minutes: 10), (){
      Navigator.of(context).pushReplacementNamed('/workout-complete');
    });
  }

  void _initialize() async {
    // get cameras
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    // set camera index
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    stopwatch.stop();
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // check if workout is complete, if so redirect
    if(widget.workoutComplete && !oneTimeRedirectFlag){
      oneTimeRedirectFlag = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
          context,
          '/workout-complete',
          // add arguments - https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#:~:text=You%20can%20accomplish%20this%20task,the%20MaterialApp%20or%20CupertinoApp%20constructor.
        );
      });
    }

    return Scaffold(
      body: _liveFeedBody(),
    );
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: _changingCameraLens
                ? Center(
                    child: const Text('Changing camera lens'),
                  )
                : CameraPreview(
                    _controller!,
                    child: widget.customPaint,
                  ),
          ),
          _backButton(),
          _switchLiveCameraToggle(),
          _stopWatch(),
          for (Widget? w in widget.overlay) w ?? Container()
        ],
      ),
    );
  }

  Widget _stopWatch() {
    return Positioned(
        bottom: 10,
        left: 10,
        child: SizedBox(
            height: 70.0,
            width: 150.0,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: Colors.grey[800]!,
                  border: Border.all(color: Colors.grey[800]!),
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: Center(
                child: Text(
                  _getStopWatchTime(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            )));
  }

  Widget _backButton() => Positioned(
        top: 40,
        left: 10,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.grey[800],
            child: Icon(
              Icons.arrow_back_ios_outlined,
              size: 20,
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
                // side: BorderSide(width: 3,color: Colors.brown),
                borderRadius: BorderRadius.circular(15)),
          ),
        ),
      );

  Widget _switchLiveCameraToggle() => Positioned(
        bottom: 8,
        right: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: _switchLiveCamera,
            backgroundColor: Colors.black54,
            child: Icon(
              Platform.isIOS
                  ? Icons.flip_camera_ios_outlined
                  : Icons.flip_camera_android_outlined,
              size: 25,
            ),
          ),
        ),
      );

  String _getStopWatchTime() {
    if(stopwatch.isRunning){
      var milli = stopwatch.elapsed.inMilliseconds;

      String milliseconds = ((milli % 1000) ~/ 10).toString().padLeft(2, "0");
      String seconds = ((milli ~/ 1000) % 60).toString().padLeft(2, "0");
      String minutes = ((milli ~/ 1000) ~/ 60).toString().padLeft(2, "0");

      return "$minutes:$seconds:$milliseconds";
    } else {
      return '';
    }
  }


  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });

      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      // print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}
