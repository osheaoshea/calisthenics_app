import 'package:flutter/material.dart';

// TODO possibly block screen rotation for this page.

class WorkoutSetupView extends StatefulWidget {
  final String nextPageRoute;

  const WorkoutSetupView({
    super.key,
    required this.nextPageRoute
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
              Image.asset('assets/images/app-2m-clear.png'), // Replace with your image path
              SizedBox(height: 20),
              for (var point in [
                'Place your phone on the floor, leaning against a suitable vertical surface.',
                'Get into workout position 2m away.',
                'Make sure your body is perpendicular to the phone.'
              ])
                Padding(
                  padding: const EdgeInsets.fromLTRB(45, 0, 45, 8.0), // Space between bullet points
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start, // Align bullet at the top
                    children: <Widget>[
                      Text('• ', textAlign: TextAlign.center), // Bullet point
                      Expanded( // Allows the text to wrap and fill the row
                        child: Text(
                          point,
                          textAlign: TextAlign.center, // Centers the text when it wraps
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),// Provides spacing between the image and the bullet points
              const SizedBox(height: 20), // Provides spacing between the bullet points and the button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, widget.nextPageRoute);
                },
                child: Text('Get into Position'),
              ),
            ],
          ),
        ),
      )
    );
  }
}
