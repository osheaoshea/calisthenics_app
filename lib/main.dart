import 'package:calisthenics_app/pages/home.dart';
import 'package:calisthenics_app/pages/pose_setup_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/home': (context) => Home(),
      '/set-up': (context) => PoseSetupView(),
      '/pose-set-up': (context) => PoseSetupView(),
      '/pose-exercise': (context) => PoseSetupView()
    },
    debugShowCheckedModeBanner: false,
  ));
}


