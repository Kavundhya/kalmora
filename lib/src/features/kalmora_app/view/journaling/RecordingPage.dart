import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'journaling_entry.dart';

class RecordingPage extends StatefulWidget {
  @override
  _RecordingPageState createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  final FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _audioFilePath = '';
  String _currentDateTime = '';

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _updateDateTime();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentDateTime = DateFormat('MMM dd, yyyy').format(now);
    });
    Future.delayed(Duration(minutes: 1), _updateDateTime);
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    if (await Permission.microphone.isGranted) {
      await _soundRecorder.openRecorder();
    } else {
      print("Microphone permission denied.");
    }
  }

  Future<String> getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<void> _startRecording() async {
    final filePath = await getFilePath('audio.mp4');
    _audioFilePath = filePath;
    await _soundRecorder.startRecorder(toFile: filePath);
    setState(() {
      _isRecording = true;
    });
    print("Recording started, file saved at: $filePath");
  }

  Future<void> _stopRecording() async {
    try {
      await _soundRecorder.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      print("Recording stopped and saved!");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JournalingEntry(
            audioFilePath: _audioFilePath,
            recordedDateTime: _currentDateTime,
          ),
        ),
      );
    } catch (e) {
      print("Error stopping recorder: $e");
    }
  }

  @override
  void dispose() {
    _soundRecorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2C0A3), // Your specified beige
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
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording
                            ? Colors.black.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: Colors.black,
                          width: _isRecording ? 3 : 2,
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
                    _isRecording ? "RECORDING..." : "TAP TO BEGIN",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _isRecording ? "Tap to finish" : "Your thoughts matter",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              SizedBox(), // Empty spacer for balance
            ],
          ),
        ),
      ),
    );
  }
}