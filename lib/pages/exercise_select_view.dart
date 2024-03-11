import 'package:flutter/material.dart';


class ExerciseSelectView extends StatefulWidget {
  const ExerciseSelectView({super.key});

  @override
  State<ExerciseSelectView> createState() => _ExerciseSelectViewState();
}

class _ExerciseSelectViewState extends State<ExerciseSelectView> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Exercise'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: ListView(
              children: [
                SizedBox(
                  height: 20,
                ),
                _exerciseButton('KNEE PUSHUP', '/knee-pushup', 10),
                _exerciseButton('PUSHUP', '/pushup', 6),
                _exerciseButton('ONE-ARM PUSHUP', '', 3)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _exerciseButton(String _text, String _route, int _reps) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: SizedBox(
        height: 70,
        child: ElevatedButton(
          onPressed: () {
            if(_route != ''){
              Navigator.pushNamed(context, _route);
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // <-- Radius
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_text, style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 15
              ),),
              SizedBox(
                width: 70,
                height: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LinearProgressIndicator(
                      backgroundColor: Colors.grey[300], // Background color of the progress bar
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getColorFromDecimal(_reps/10)
                      ), // Fill color
                      value: _reps / 10, // Set the progress value between 0.0 and 1.0
                    ),
                    Text("$_reps/10", style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 12
                    ),)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromDecimal(double decimal) {
    // Ensure the decimal is within the valid range [0, 1]
    decimal = decimal.clamp(0.0, 1.0);

    if (decimal == 1.0) {
      return Colors.green;
    }

    // Calculate the color values between red and yellow based on the decimal
    int red = 255;
    int green = (255 * decimal).round();
    int blue = 0;

    // Return the resulting color
    return Color.fromARGB(255, red, green, blue);
  }
}


