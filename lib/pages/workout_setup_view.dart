import 'package:calisthenics_app/common/workout_metadata.dart';
import 'package:calisthenics_app/pages/workout_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class WorkoutSetupView extends StatefulWidget {
  final WorkoutMetadata workoutMetadata;

  const WorkoutSetupView({
    super.key,
    required this.workoutMetadata
  });

  @override
  State<WorkoutSetupView> createState() => _WorkoutSetupViewState();
}

class _WorkoutSetupViewState extends State<WorkoutSetupView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Setup'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/app-2m-clear.png'),
              SizedBox(height: 20),
              for (var point in [
                'Place your phone on the floor, leaning against a suitable vertical surface.',
                'Get into workout position 2-3m away.',
                'Make sure your body is perpendicular to the phone.',
                'The app will inform you when the workout has begun.'
              ])
                Padding(
                  padding: const EdgeInsets.fromLTRB(45, 0, 45, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('• ', textAlign: TextAlign.center),
                      Expanded(
                        child: Text(
                          point,
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigator.pushReplacementNamed(context, widget.workoutMetadata.route);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => WorkoutView(
                        workoutMetadata: widget.workoutMetadata,
                      ))
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // <-- Radius
                  ),
                ),
                child: Text('Get into Position', style: TextStyle(color: Colors.grey[800]),),
              ),
            ],
          ),
        ),
      )
    );
  }
}
