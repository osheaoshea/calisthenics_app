import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/pose-set-up');
          },
          child: Text('START'),
        ),
      ),
    );
  }
}

