import 'package:calisthenics_app/pages/exercise_select_view.dart';
import 'package:calisthenics_app/pages/home.dart';
import 'package:calisthenics_app/pages/pose_setup_view.dart';
import 'package:calisthenics_app/pages/workout_complete.dart';
import 'package:calisthenics_app/pages/workout_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/exercise-select',
    routes: {
      '/home': (context) => Home(),
      '/set-up': (context) => PoseSetupView(),
      '/pose-set-up': (context) => PoseSetupView(),
      '/exercise-select': (context) => ExerciseSelectView(),
      '/workout': (context) => WorkoutView(),
      '/workout-complete': (context) => WorkoutCompleteView()
    },
    debugShowCheckedModeBanner: false,
  ));
}


