import 'package:calisthenics_app/common/exercise_phase.dart';

class PhaseTracker {
  ExercisePhase _currentPhase = ExercisePhase.NA;
  ExercisePhase _previousPhase = ExercisePhase.NA;
  int _phaseCounter = 0; // track how long we have been in a given phase
  late int _phaseLimit;

  ExercisePhase get currentPhase => _currentPhase;
  ExercisePhase get previousPhase => _previousPhase;
  int get phaseCounter => _phaseCounter;

  PhaseTracker(int phaseLimit) {
    _phaseLimit = phaseLimit;
  }

  void setPhase(ExercisePhase phase) {
    _currentPhase = phase;
  }

  void updatePhaseCounter() {
    if (_currentPhase == _previousPhase) {
      _phaseCounter ++;
    } else {
      _phaseCounter = 0;
      _previousPhase = _currentPhase;
    }
  }

  bool ifDownPhase() {
    return _currentPhase == ExercisePhase.DOWN;
  }

  bool ifUpPhase() {
    return _currentPhase == ExercisePhase.UP;
  }

  bool ifTopPhase() {
    return _currentPhase == ExercisePhase.TOP;
  }

  bool ifBottomPhase() {
    return _currentPhase == ExercisePhase.BOTTOM;
  }

  bool checkLimitDown() {
    return ifDownPhase() && _phaseCounter > _phaseLimit;
  }

  bool checkLimitUp() {
    return ifUpPhase() && _phaseCounter > _phaseLimit;
  }
}
