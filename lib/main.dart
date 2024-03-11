import 'package:calisthenics_app/pages/exercise_select_view.dart';
import 'package:calisthenics_app/pages/home.dart';
import 'package:calisthenics_app/pages/pose_setup_view.dart';
import 'package:calisthenics_app/pages/workout_complete_view.dart';
import 'package:calisthenics_app/pages/workout_view.dart';
import 'package:flutter/material.dart';

import 'package:calisthenics_app/common/exercise_type.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/exercise-select',
    routes: {
      '/home': (context) => Home(),
      // '/set-up': (context) => PoseSetupView(),
      // '/pose-set-up': (context) => PoseSetupView(),
      '/exercise-select': (context) => ExerciseSelectView(),
      '/pushup': (context) => WorkoutView(exerciseType: ExerciseType.PUSHUP),
      '/knee-pushup': (context) => WorkoutView(exerciseType: ExerciseType.KNEE_PUSHUP),
      '/workout-complete': (context) => WorkoutCompleteView()
    },
    debugShowCheckedModeBanner: false,
  ));
}


