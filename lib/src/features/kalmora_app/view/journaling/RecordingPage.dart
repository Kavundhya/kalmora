import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../controller/recording_controller.dart';
import 'journaling_entry.dart';

class RecordingPage extends StatefulWidget {
  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  final RecordingController _controller = RecordingController();
  String _currentDateTime = '';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _controller.initRecorder();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentDateTime = DateFormat('MMM dd, yyyy').format(now);
    });
    Future.delayed(Duration(minutes: 1), _updateDateTime);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2C0A3),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: 600,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFD2C0A3).withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "SPEAK YOUR MIND",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _currentDateTime,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 24),
                  Divider(
                    color: Colors.black.withOpacity(0.2),
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (_controller.isRecording) {
                        await _controller.stopRecording();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JournalingEntryScreen(
                              audioFilePath: _controller.audioFilePath,
                              recordedDateTime: _currentDateTime,
                            ),
                          ),
                        );
                      } else {
                        await _controller.startRecording();
                      }
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.isRecording
                            ? Colors.black.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: Colors.black,
                          width: _controller.isRecording ? 3 : 2,
                        ),
                      ),
                      child: Icon(
                        Icons.mic,
                        size: 60,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    _controller.isRecording ? "RECORDING..." : "TAP TO BEGIN",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _controller.isRecording ? "Tap to finish" : "Your thoughts matter",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}