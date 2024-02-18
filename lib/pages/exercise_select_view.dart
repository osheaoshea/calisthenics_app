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
                _exerciseButton('KNEE PUSHUP', ''),
                _exerciseButton('PUSHUP', '/workout'),
                _exerciseButton('ONE-ARM PUSHUP', '')
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _exerciseButton(String _text, String _route) {
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
          child: Text(_text, style: TextStyle(
            color: Colors.grey[800],
            fontSize: 15
          ),),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // <-- Radius
            ),
          ),
        ),
      ),
    );
  }
}


