import 'package:flutter/material.dart';

import '../painters/ring_painter.dart';


class WorkoutCompleteView extends StatefulWidget {
  const WorkoutCompleteView({super.key});

  @override
  State<WorkoutCompleteView> createState() => _WorkoutCompleteViewState();
}

class _WorkoutCompleteViewState extends State<WorkoutCompleteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Complete'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Congratulations!', style: TextStyle(
                fontSize: 30,
                letterSpacing: 1
              ),),
              Text('You completed the workout', style: TextStyle(
                fontSize: 15,
                letterSpacing: 1,
              ),),
              SizedBox(height: 20,),
              PercentageRing(percentage: 1.0)
            ],
          ),
        ),
      ),
    );
  }
}
