import 'package:calisthenics_app/pages/exercise_select_view.dart';
import 'package:calisthenics_app/pages/home.dart';
// import 'package:calisthenics_app/pages/tutorial_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/home': (context) => Home(),
      '/exercise-select': (context) => ExerciseSelectView(),
      // '/tutorial': (context) => TutorialView(),
    },
    debugShowCheckedModeBanner: false,
  ));
}


