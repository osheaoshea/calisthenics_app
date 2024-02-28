class PushUpAngles {
  final double startArmAngleMax = 181.0;
  final double startArmAngleMin = 155.0;//180;//
  final double endArmAngleMax = 95.0;//30;//
  final double endArmAngleMin = 10;
  final double hipAngleMax = 190;
  final double hipAngleMin = 150;
  final double legAngleMax = 180;
  final double legAngleMin = 155;//179;//

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

  bool checkLegAngles(right, left) {
    return right < legAngleMax &&
        right > legAngleMin &&
        left < legAngleMax &&
        left > legAngleMin;
  }

// TODO - possibly check occlusion/likelihood (if < threshold, don't track that arm)
}