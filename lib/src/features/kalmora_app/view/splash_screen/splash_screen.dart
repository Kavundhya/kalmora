import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../welcome/about_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/kalmora_logo.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(false);

        // Wait for the video to finish playing
        _controller.addListener(() {
          if (!_controller.value.isPlaying && _controller.value.position == _controller.value.duration) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => AboutScreen()),
              );
            }
          }
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9D7B6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_controller.value.isInitialized)
              Container(
                color: Color(0xFFE9D7B6),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            SizedBox(height: 10),
            Text(
              "Your Personal Journaling Companion\nWith Voice\nEmotion Detection\nAnd Well-being",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium, // Updated
            ),
          ],
        ),
      ),
    );
  }
}
