/**
 * String = form mistake
 * double (1) = use of existing angle (0-1)
 * double (2) = value to add to existing angle (degrees)
 */

Map<String, (double, double)> bottomArms = {
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

Map<String, (double, double)> topArms = {
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

Map<String, (double, double)> highHips = {
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

Map<String, (double, double)> lowHips = {
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

Map<String, (double, double)> bentLegs = {
  'leftForearm': (1, 0),
  'leftBicep': (1, 0),
  'leftBody': (1, 0),
  'leftQuad': (0, 200),
  'leftCalf': (0, 200),

  'rightForearm': (1, 0),
  'rightBicep': (1, 0),
  'rightBody': (1, 0),
  'rightQuad': (0, 200),
  'rightCalf': (0, 200),

  'toNose': (1, 0),
};