/*

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TutorialView extends StatefulWidget {
  const TutorialView({super.key});

  @override
  State<TutorialView> createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  // Define the YouTube video IDs
  final List<String> _videoIds = [
    'jWxvty2KROs', // Replace with actual YouTube video ID
    'jWxvty2KROs', // Replace with actual YouTube video ID
    'jWxvty2KROs', // Replace with actual YouTube video ID
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _videoIds.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: YoutubePlayer(
            controller: YoutubePlayerController(
              initialVideoId: _videoIds[index],
              flags: YoutubePlayerFlags(
                autoPlay: false,
                mute: false,
              ),
            ),
            showVideoProgressIndicator: true,
          ),
        );
      },
    );
  }
}

 */

