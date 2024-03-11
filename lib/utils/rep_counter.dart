class RepCounter {
  int _reps = 0;
  late int _repGoal;

  RepCounter(int repGoal) {
    _repGoal = repGoal;
  }

  void increment() {
    _reps++;
  }

  bool checkGoal() {
    return _reps >= _repGoal;
  }

  int get reps => _reps;
}