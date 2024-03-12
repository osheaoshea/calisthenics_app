import 'package:calisthenics_app/common/exercise_type.dart';
import 'package:calisthenics_app/common/form_mistake.dart';
import 'package:calisthenics_app/utils/workout_stat_tracker.dart';
import 'package:flutter/material.dart';

import '../widgets/card_list.dart';

/// USED FOR DEBUGGING

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  StatTracker statTracker = StatTracker(10, ExerciseType.PUSHUP);
  bool oneTimeRedirectFlag = false;

  _updateStats() {
    statTracker.mistakeCounter[FormMistake.HIGH_HIPS] = 10;
    statTracker.mistakeCounter[FormMistake.TOP_ARMS] = 19;
    statTracker.mistakeCounter[FormMistake.BOTTOM_ARMS] = 21;
    // statTracker.mistakeCounter[FormMistake.BENT_LEGS] = 14;

    statTracker.completedReps = 8;

    statTracker.setCompletionDate();
  }

  @override
  Widget build(BuildContext context) {

    _updateStats();

    if(!oneTimeRedirectFlag) {
      oneTimeRedirectFlag = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(
            context,
            '/workout-complete',
            arguments: statTracker
          // add arguments - https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#:~:text=You%20can%20accomplish%20this%20task,the%20MaterialApp%20or%20CupertinoApp%20constructor.
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
      ),
      // body: SafeArea(
      //   child: Center(
      //     child: FractionallySizedBox(
      //       widthFactor: 0.8,
      //         child: CardList(numbers: [1, 2, 9],)
      //     )
      //   )
      // ),
    );
  }
}



