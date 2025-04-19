import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class RecordingController {
  final FlutterSoundRecorder _soundRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _audioFilePath = '';

  bool get isRecording => _isRecording;
  String get audioFilePath => _audioFilePath;

  Future<void> initRecorder() async {
    await Permission.microphone.request();
    if (await Permission.microphone.isGranted) {
      await _soundRecorder.openRecorder();
    } else {
      print("Microphone permission denied.");
    }
  }

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<void> startRecording() async {
    final filePath = await _getFilePath('audio.mp4');
    _audioFilePath = filePath;
    await _soundRecorder.startRecorder(toFile: filePath);
    _isRecording = true;
    print("Recording started, file saved at: $filePath");
  }

  Future<void> stopRecording() async {
    try {
      await _soundRecorder.stopRecorder();
      _isRecording = false;
      print("Recording stopped and saved!");
    } catch (e) {
      print("Error stopping recorder: $e");
    }
  }

  Future<void> dispose() async {
    await _soundRecorder.closeRecorder();
  }
}