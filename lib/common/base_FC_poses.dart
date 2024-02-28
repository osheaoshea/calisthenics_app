// base abstract class for FC visual poses
abstract class BaseFCPoses {
  Map<String, (double, double)> get bottomArms;
  Map<String, (double, double)> get topArms;
  Map<String, (double, double)> get highHips;
  Map<String, (double, double)> get lowHips;
  Map<String, (double, double)> get bentLegs;
}