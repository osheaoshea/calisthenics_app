import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TutorialView extends StatelessWidget {
  const TutorialView({super.key});

  // Define URLs for each image
  final String url1 = 'https://www.youtube.com/watch?v=jWxvty2KROs';
  final String url2 = 'https://www.youtube.com/watch?v=IODxDxX7oi4';

  // Function to launch URL
  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Workout Tutorials',
          ),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                Text('Knee Pushup Tutorial'),
                SizedBox(height: 20),
                _buildImage(url1, 'assets/images/knee-pushup.png'),
                SizedBox(height: 20),
                Text('Pushup Tutorial'),
                SizedBox(height: 20),
                _buildImage(url2, 'assets/images/pushup.png')
              ],
            ),
          ),
        )));
  }

  /// Code adapted from: How can I add shadow to the widget in flutter?; Stack Overflow; 2018;
  /// https://stackoverflow.com/questions/52227846/how-can-i-add-shadow-to-the-widget-in-flutter
  /// Accessed: 17/03/2024
  Widget _buildImage(String url, String imgPath) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _launchURL(url),
        child: Image.asset(imgPath),
      ),
    );
  }
}