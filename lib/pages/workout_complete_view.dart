import 'package:audioplayers/audioplayers.dart';
import 'package:calisthenics_app/common/exercise_type.dart';
import 'package:calisthenics_app/common/form_mistake.dart';
import 'package:calisthenics_app/common/workout_metadata.dart';
import 'package:calisthenics_app/utils/workout_stat_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../painters/ring_painter.dart';
import '../utils/shared_preferences_notifier.dart';


class WorkoutCompleteView extends StatefulWidget {
  const WorkoutCompleteView({
    super.key,
    required this.workoutMetadata,
    required this.statTracker
  });

  final WorkoutMetadata workoutMetadata;
  final StatTracker statTracker;

  @override
  State<WorkoutCompleteView> createState() => _WorkoutCompleteViewState();
}

class _WorkoutCompleteViewState extends State<WorkoutCompleteView> {

  late List<Map<String, dynamic>> _FCitems;
  bool perfectWorkout = false;
  // late StatTracker stats;

  bool oneTimeUpdateFlag = false;

  void _populateItems(StatTracker stats) {
    _FCitems = [
      {"title": "Hips out of place", "number": (stats.mistakeCounter[FormMistake.LOW_HIPS]!
          + stats.mistakeCounter[FormMistake.HIGH_HIPS]!),
        "description": "Try raising or lowering your hips to straighten them out, "
            "focusing on improving core strength will help with this."},
      {"title": "Not going low enough", "number": stats.mistakeCounter[FormMistake.BOTTOM_ARMS]!,
        "description": "Try going lower into each rep, getting your chest closer to the floor."},
      {"title": "Not straightening arms", "number": stats.mistakeCounter[FormMistake.TOP_ARMS]!,
        "description": "Try straightening your arms at the top of each rep to successfully complete the rep."},
    ];

    switch(stats.exerciseType){
      case ExerciseType.PUSHUP:
        _FCitems.add({"title": "Legs not straight", "number": stats.mistakeCounter[FormMistake.BENT_LEGS]!,
          "description": "Try keeping your legs straight throughout the entire workout."});
      case ExerciseType.KNEE_PUSHUP:
        _FCitems.add({"title": "Legs out of place", "number": (stats.mistakeCounter[FormMistake.BEND_LEGS_MORE]!
            + stats.mistakeCounter[FormMistake.BEND_LEGS_LESS]!),
          "description": "Try keeping your legs at 90 degrees for the entire workout, "
              "only your knees should be touching the floor with your feet in the air."});
    }

    _FCitems.sort((a, b) => b['number'].compareTo(a['number']));

    perfectWorkout = _FCitems.every((item) => item['number'] == 0);

    _FCitems.removeWhere((item) => item['number'] == 0);

    setState(() {});
  }

  void _updatePrefs(StatTracker stats) async {
    SharedPreferencesNotifier().incrementWorkoutCompletion(widget.workoutMetadata.id);
  }

  @override
  void initState() {
    // lock orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // play workout complete message
    AudioPlayer().play(AssetSource('audio/workout-complete-message.mp3'));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // stats = ModalRoute.of(context)!.settings.arguments as StatTracker;
    _populateItems(widget.statTracker);

    if(!oneTimeUpdateFlag){
      _updatePrefs(widget.statTracker);
      oneTimeUpdateFlag = true;
    }

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
              const Text('Congratulations!', style: TextStyle(
                fontSize: 30,
                letterSpacing: 1
              ),),
              const Text('You completed the workout', style: TextStyle(
                fontSize: 15,
                letterSpacing: 1,
              ),),
              Text(widget.statTracker.completionDate),
              const SizedBox(height: 20,),
              PercentageRing(percentage: (widget.statTracker.completedReps / widget.statTracker.goalReps)),
              const SizedBox(height: 20,),
              FractionallySizedBox(
                widthFactor: 0.8,
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 5,),
                        Text('Time Stats', style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold
                        ),),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Text('Completion Time : ${widget.statTracker.completionTime}'),
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              const FractionallySizedBox(
                widthFactor: 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 5,),
                    Text('Form Mistakes', style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold
                    ),),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              perfectWorkout
                  ? Container(
                      height: 80,
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0), // Adjust padding as needed
                      decoration: BoxDecoration(
                        color: Colors.lightGreen[100], // Light green background color
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Well Done!', style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              color: Colors.green
                           ),),
                          Text('No mistakes were made.', style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold,
                              color: Colors.green
                          ),),
                        ],
                    ),
                  )
                  : Expanded(
                      child: FractionallySizedBox(
                          widthFactor: 0.8,
                          child: _formMistakeList()
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formMistakeList() {
    return ListView.builder(
        itemCount: _FCitems.length,
        itemBuilder: (context, index)
        {
          final item = _FCitems[index];
          return _formMistakeCard(item['title'], item['number'], item['description']);
        }
    );
  }

  Widget _formMistakeCard(String _title, int _number, String _desc) {
    return Card(
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_title, style: TextStyle(
                fontSize: 14,
                letterSpacing: 0.65,
              ),),
              Text(
                "${_number}",
                style: TextStyle(
                    color: _getColorForNumber(_number),
                    fontSize: 20,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          trailing: Transform.scale(
            scale: 0.75,
            child: Icon(Icons.expand_more),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _desc,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForNumber(int number) {
    if (number < 3) {
      return Colors.yellow;
    } else if (number < 5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

}


