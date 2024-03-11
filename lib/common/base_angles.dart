// base class for exercise angles (defaults to pushup angles)

abstract class BaseAngles {
  final double startArmAngleMax = 181.0;
  final double startArmAngleMin = 155.0;//180;//
  final double endArmAngleMax = 95.0;//30;//
  final double endArmAngleMin = 10;
  final double hipAngleMax = 190;
  final double hipAngleMin = 150;
  final double legAngleMax = 180;
  final double legAngleMin = 155;//179;//

  // todo - implement shared angle code
  bool checkStartArmAngles(double right, double left) {
    return right < startArmAngleMax &&
        right > startArmAngleMin &&
        left < startArmAngleMax &&
        left > startArmAngleMin;
  }

  bool checkEndArmAngles(double right, double left) {
    return right < endArmAngleMax &&
        right > endArmAngleMin &&
        left < endArmAngleMax &&
        left > endArmAngleMin;
  }

  bool checkHipAngles(double right, double left) {
    return right < hipAngleMax &&
        right > hipAngleMin &&
        left < hipAngleMax &&
        left > hipAngleMin;
  }

  bool checkLegAngles(double right, double left) {
    return right < legAngleMax &&
        right > legAngleMin &&
        left < legAngleMax &&
        left > legAngleMin;
  }

  int checkKneeAngles(double right, double left) {
    return 0;
  }
}