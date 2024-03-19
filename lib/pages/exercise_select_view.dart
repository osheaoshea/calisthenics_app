import 'package:calisthenics_app/common/workout_metadata.dart';
import 'package:calisthenics_app/pages/settings_view.dart';
import 'package:calisthenics_app/pages/workout_setup_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/exercise_type.dart';
import '../utils/shared_preferences_notifier.dart';


class ExerciseSelectView extends StatefulWidget {
  const ExerciseSelectView({super.key});

  @override
  State<ExerciseSelectView> createState() => _ExerciseSelectViewState();
}

class _ExerciseSelectViewState extends State<ExerciseSelectView> {

  // int? test_value;
  UserData userData = UserData();

  @override
  void initState() {
    // lock orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();

    loadData();

    SharedPreferencesNotifier().stream.listen((updatedCount) {
      loadData();
    });
  }

  Future<void> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userData.KP_1 = prefs.getInt('KP_1');
      userData.KP_2 = prefs.getInt('KP_2');
      userData.KP_3 = prefs.getInt('KP_3');
      userData.FP_1 = prefs.getInt('FP_1');
      userData.FP_2 = prefs.getInt('FP_2');
      userData.FP_3 = prefs.getInt('FP_3');
    });
  }

  int _getCompletion(ExerciseType _type) {
    int count = 0;
    switch(_type){
      case ExerciseType.KNEE_PUSHUP:
        if (userData.KP_1 != null) {
          if (userData.KP_1! > 0) {
            count += 1;
          }
        }
        if (userData.KP_2 != null) {
          if (userData.KP_2! > 0) {
            count += 1;
          }
        }
        if (userData.KP_3 != null) {
          if (userData.KP_3! > 0) {
            count += 1;
          }
        }
        return count;
      case ExerciseType.PUSHUP:
        if (userData.FP_1 != null) {
          if (userData.FP_1! > 0) {
            count += 1;
          }
        }
        if (userData.FP_2 != null) {
          if (userData.FP_2! > 0) {
            count += 1;
          }
        }
        if (userData.FP_3 != null) {
          if (userData.FP_3! > 0) {
            count += 1;
          }
        }
        return count;
      default:
        return count;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Workout'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      _exerciseExpand(
                        'Knee Pushup',
                        _getCompletion(ExerciseType.KNEE_PUSHUP)
                      ),
                      _exerciseExpand(
                          'Pushup',
                          _getCompletion(ExerciseType.PUSHUP)
                      ),
                      _exerciseExpand(
                          'One-Arm Pushup',
                          0
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsView())
                    );
                },
                child: Icon(Icons.settings, color: Colors.grey[800],),
                backgroundColor: Colors.grey[100],
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _exerciseExpand(String _text, int _completion) {

    String id_prefix = '';
    ExerciseType ex_type = ExerciseType.PUSHUP;

    if (_text == 'Knee Pushup') {
      id_prefix = 'KP';
      ex_type = ExerciseType.KNEE_PUSHUP;
    } else if (_text == 'Pushup') {
      id_prefix = 'FP';
      ex_type = ExerciseType.PUSHUP;
    }

    return Card(
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_text, style: TextStyle(
                fontSize: 14,
                letterSpacing: 0.65,
              ),),
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[300], // Background color of the progress bar
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _getColorFromDecimal(_completion/3)
                  ), // Fill color
                  value: _completion / 3, // Set the progress value between 0.0 and 1.0
                ),
              ),
            ],
          ),
          trailing: Transform.scale(
            scale: 0.75,
            child: Icon(Icons.expand_more),
          ),
          children: <Widget>[
            SizedBox(height: 10,),
            _workoutCardButton(
                'Level 1  |  3 reps',
                WorkoutMetadata('${id_prefix}_1', 3, ex_type),
                _text == 'Knee Pushup'
                    ? userData.KP_1 ?? 0
                    : userData.FP_1 ?? 0,
                false
            ),
            SizedBox(height: 10,),
            _workoutCardButton(
                'Level 2  |  8 reps',
                WorkoutMetadata('${id_prefix}_2', 8, ex_type),
                _text == 'Knee Pushup'
                    ? userData.KP_2 ?? 0
                    : userData.FP_2 ?? 0,
                _text == 'Knee Pushup'
                    ? (userData.KP_1 == null || userData.KP_1 == 0)
                    : (userData.FP_1 == null || userData.FP_1 == 0)
            ),
            SizedBox(height: 10,),
            _workoutCardButton(
                'Level 3  |  12 reps',
                WorkoutMetadata('${id_prefix}_3', 12, ex_type),
                _text == 'Knee Pushup'
                    ? userData.KP_3 ?? 0
                    : userData.FP_3 ?? 0,
                _text == 'Knee Pushup'
                    ? (userData.KP_2 == null || userData.KP_2 == 0)
                    : (userData.FP_2 == null || userData.FP_2 == 0)
            ),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }

  Widget _workoutCardButton(String _text, WorkoutMetadata _metadata, int _sets, bool _lock) {
    return SizedBox(
      height: 70,
      child: FractionallySizedBox(
        widthFactor: 0.95,
        child: ElevatedButton(
          onPressed: () {
            if(!_lock) {
              if(_metadata.id != ''){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WorkoutSetupView(
                        workoutMetadata: _metadata
                    ))
                );
              }
            } else {
              // show are you sure message
              _showConfirmationDialog(context, _metadata);
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // <-- Radius
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_text, style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 13
              ),),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Completed:', style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 12
                  ),),
                  Text('$_sets', style: TextStyle(
                    color: _sets > 0 ? Colors.green : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),)
                ],
              ),
              _lock
                  ? Icon(Icons.lock_outline, color: Colors.grey[800],)
                  : Icon(Icons.lock_open_outlined, color: Colors.green,)
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, WorkoutMetadata _metadata) {
    // Show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Start Workout?'),
          content: Text(
              'We recommend doing the previous level before attempting this one. '
                  'But if you are confident go for it :)'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog but do nothing else
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        WorkoutSetupView(
                            workoutMetadata: _metadata
                        ))
                );
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
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

  Widget _valueCircle(int value) {
    return Container(
      width: 40.0, // Circle size
      height: 40.0, // Circle size
      decoration: BoxDecoration(
        color: value > 0 ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: value > 0
            ? Text(
          '$value',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        )
            : Container(), // If value is not above 0, we don't display anything.
      ),
    );
  }
}

class UserData{
  int? KP_1;
  int? KP_2;
  int? KP_3;
  int? FP_1;
  int? FP_2;
  int? FP_3;

  UserData();
}


