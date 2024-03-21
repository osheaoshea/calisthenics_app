import 'dart:math';

import 'package:google_ml_kit/google_ml_kit.dart';

/// Code adapted from: Pose classification options; Google ML Kit;
/// Available from: https://developers.google.com/ml-kit/vision/pose-detection/classifying-poses
/// Accessed: 31/01/2024

double findAngle(PoseLandmark first, PoseLandmark mid, PoseLandmark last) {
  double radians = atan2(last.y - mid.y, last.x - mid.x) -
      atan2(first.y - mid.y, first.x - mid.x);

  double degrees = (radians * 180.0 / pi).abs();

  if (degrees > 180.0) {
    degrees = 360.0 - degrees;
  }

  return degrees;
}