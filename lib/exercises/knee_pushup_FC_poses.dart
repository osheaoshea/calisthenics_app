import 'package:calisthenics_app/common/base_FC_poses.dart';

/**
 * String = form mistake
 * double (1) = use of existing angle (0-1)
 * double (2) = value to add to existing angle (degrees)
 */

class KneePushupFCPoses implements BaseFCPoses {
  @override
  Map<String, (double, double)> get bottomArms => {
    'leftForearm': (1, 0),
    'leftBicep': (1, -20),
    'leftBody': (1, 0),
    'leftQuad': (1, 0),
    'leftCalf': (1, 0),

    'rightForearm': (1, 0),
    'rightBicep': (1, -20),
    'rightBody': (1, 0),
    'rightQuad': (1, 0),
    'rightCalf': (1, 0),

    'toNose': (1, 0),
  };

  @override
  Map<String, (double, double)> get topArms => {
    'leftForearm': (0, 90),
    'leftBicep': (0, 90),
    'leftBody': (1, 0),
    'leftQuad': (1, 0),
    'leftCalf': (1, 0),

    'rightForearm': (0, 90),
    'rightBicep': (0, 90),
    'rightBody': (1, 0),
    'rightQuad': (1, 0),
    'rightCalf': (1, 0),

    'toNose': (1, 0),
  };

  @override
  Map<String, (double, double)> get highHips => {
    'leftForearm': (1, 0),
    'leftBicep': (1, 0),
    'leftBody': (1, 0),
    'leftQuad': (1, 0),
    'leftCalf': (1, 0),

    'rightForearm': (1, 0),
    'rightBicep': (1, 0),
    'rightBody': (1, 0),
    'rightQuad': (1, 0),
    'rightCalf': (1, 0),

    'toNose': (1, 0),
  };

  @override
  Map<String, (double, double)> get lowHips => {
    'leftForearm': (1, 0),
    'leftBicep': (1, 0),
    'leftBody': (0, 200),
    'leftQuad': (0, 200),
    'leftCalf': (1, 0),

    'rightForearm': (1, 0),
    'rightBicep': (1, 0),
    'rightBody': (0, 200),
    'rightQuad': (0, 200),
    'rightCalf': (1, 0),

    'toNose': (1, 0),
  };

  @override
  Map<String, (double, double)> get bentLegs => {
    'leftForearm': (1, 0),
    'leftBicep': (1, 0),
    'leftBody': (1, 0),
    'leftQuad': (0, 200),
    'leftCalf': (0, 100),

    'rightForearm': (1, 0),
    'rightBicep': (1, 0),
    'rightBody': (1, 0),
    'rightQuad': (0, 200),
    'rightCalf': (0, 100),

    'toNose': (1, 0),
  };
}