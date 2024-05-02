import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('CaliCorrect',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
              child: Column(
                children: [
                  const SizedBox(height: 20,),
                  Text('Welcome to CaliCorrect - a computer vision mobile app to '
                      'help you ascent through the calisthenic levels!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40,),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/exercise-select');
                    },
                    icon: Icon(Icons.fitness_center, color: Colors.grey[800],),
                    label: Text('Select Workout', style: TextStyle(color: Colors.grey[800]),),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      textStyle: TextStyle(
                        fontSize: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // <-- Radius
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/tutorial');
                    },
                    icon: Icon(Icons.question_mark, color: Colors.grey[800],),
                    label: Text('Workout Tutorials', style: TextStyle(color: Colors.grey[800]),),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      textStyle: TextStyle(
                        fontSize: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // <-- Radius
                      ),
                    ),
                  ),
                ],
              )
          )
        )
      ),
    );
  }
}



