import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;

import '../../model/journal_entry_model.dart';
import '../../services/journal_service.dart';

class JournalingEntry extends StatefulWidget {
  final String audioFilePath;
  final String recordedDateTime;
  final String? entryId;

  JournalingEntry({
    required this.audioFilePath,
    required this.recordedDateTime,
    this.entryId,
  });

  @override
  _JournalingEntryState createState() => _JournalingEntryState();
}

class _JournalingEntryState extends State<JournalingEntry> {
  final FlutterSoundPlayer _soundPlayer = FlutterSoundPlayer();
  final JournalService _journalService = JournalService();
  bool _isPlaying = false;
  String _predictedEmotion = "";
  String _recommendation = "";
  String _voiceAnalysis = "";
  List<String> _suggestions = [];
  String _positiveThought = "";
  bool _isSaving = false;
  bool _isSaved = false;
  JournalEntryModel? _existingEntry;

  // Elegant color scheme using only 0xFFDCC9A0 and Black
  final Color primaryColor = Color(0xFFDCC9A0);
  final Color textColor = Colors.black;
  final Color darkPrimaryColor = Color(0xFFDCC9A0).withOpacity(0.7);
  final Color lightPrimaryColor = Color(0xFFDCC9A0).withOpacity(0.3);

  @override
  void initState() {
    super.initState();
    _initPlayer();
    if (widget.entryId != null) {
      _loadExistingEntry();
    }
  }

  Future<void> _initPlayer() async {
    await _soundPlayer.openPlayer();
  }

  Future<void> _startPlayback() async {
    final filePath = widget.audioFilePath;
    final file = File(filePath);

    if (file.existsSync()) {
      await _soundPlayer.startPlayer(fromURI: filePath);
      setState(() => _isPlaying = true);
      _soundPlayer.onProgress!.listen((event) {
        if (event.duration == event.position) {
          setState(() => _isPlaying = false);
        }
      });
    }
  }

  Future<void> _stopPlayback() async {
    await _soundPlayer.stopPlayer();
    setState(() => _isPlaying = false);
  }

  Future<void> _predictEmotion() async {
    final filePath = widget.audioFilePath;
    final file = File(filePath);

    if (file.existsSync()) {
      final uri = Uri.parse('https://93a5-34-148-233-245.ngrok-free.app/predict');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('audio', filePath));

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final predictions = jsonDecode(responseBody);
          final emotion = predictions['predictions'][0]['emotion'];

          setState(() {
            _predictedEmotion = emotion.toUpperCase();
            _setEmotionBasedContent(emotion.toLowerCase());
          });
        }
      } catch (e) {
        setState(() {
          _predictedEmotion = "ERROR";
          _voiceAnalysis = "Unable to analyze your voice tone";
          _suggestions = ["Try again later", "Check your internet connection"];
          _positiveThought = "Every day is a new opportunity";
        });
      }
    }
  }

  Future<void> _loadExistingEntry() async {
    if (widget.entryId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('journal_entries')
          .doc(widget.entryId)
          .get();

      if (snapshot.exists) {
        final entry = JournalEntryModel.fromFirestore(snapshot);
        setState(() {
          _existingEntry = entry;
          _predictedEmotion = entry.emotion.toUpperCase();
          _voiceAnalysis = entry.voiceAnalysis;
          _suggestions = entry.suggestions;
          _positiveThought = entry.positiveThought;
          _isSaved = true;
        });

        if (entry.audioFileUrl.isNotEmpty) {
          final fileName = entry.audioFileUrl.split('/').last;
          await _journalService.downloadAudioFile(entry.audioFileUrl, fileName);
        }
      }
    } catch (e) {
      print('Error loading existing entry: $e');
    }
  }

  Future<void> _saveEntry() async {
    setState(() => _isSaving = true);
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please login to save entries'),
              backgroundColor: Colors.black,
            )
        );
        return;
      }

      final entry = JournalEntryModel(
        id: '', // Firestore will generate ID
        userId: user.uid,
        audioFileUrl: '', // Will be set after upload
        localAudioPath: widget.audioFilePath,
        recordedDateTime: widget.recordedDateTime,
        emotion: _predictedEmotion.toLowerCase(),
        suggestions: _suggestions,
        voiceAnalysis: _voiceAnalysis,
        positiveThought: _positiveThought,
      );

      await _journalService.saveJournalEntry(entry, File(widget.audioFilePath));
      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Journal entry saved successfully'),
            backgroundColor: Colors.black,
          )
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: Colors.black,
          )
      );
    }
  }

  void _setEmotionBasedContent(String emotion) {
    switch (emotion) {
      case 'neutral':
        _voiceAnalysis = "YOUR VOICE SUGGESTS YOU'RE FEELING BALANCED TODAY";
        _suggestions = [
          "• Take a mindful walk in nature",
          "• Journal about your current thoughts",
          "• Try a new hobby or activity"
        ];
        _positiveThought = "YOUR STABILITY IS A GIFT. KEEP FINDING JOY IN THE ORDINARY MOMENTS.";
        break;
      case 'calm':
        _voiceAnalysis = "YOUR VOICE RADIATES PEACE AND SERENITY";
        _suggestions = [
          "• Practice gratitude meditation",
          "• Enjoy a warm cup of tea mindfully",
          "• Share your calm energy with others"
        ];
        _positiveThought = "YOUR INNER PEACE IS CONTAGIOUS. THE WORLD NEEDS MORE OF YOUR CALM ENERGY.";
        break;
      case 'happy':
        _voiceAnalysis = "YOUR VOICE IS FULL OF JOY AND POSITIVITY!";
        _suggestions = [
          "• Spread your happiness to others",
          "• Dance to your favorite upbeat songs",
          "• Capture this moment in a journal"
        ];
        _positiveThought = "YOUR HAPPINESS LIGHTS UP THE WORLD. KEEP SHINING YOUR BRIGHT LIGHT!";
        break;
      case 'sad':
        _voiceAnalysis = "YOUR VOICE SHOWS YOU'RE FEELING DOWN";
        _suggestions = [
          "• Reach out to a trusted friend",
          "• Watch comforting movies or shows",
          "• Be gentle with yourself today"
        ];
        _positiveThought = "THIS FEELING IS TEMPORARY. YOU HAVE SURVIVED 100% OF YOUR WORST DAYS SO FAR.";
        break;
      case 'angry':
        _voiceAnalysis = "YOUR VOICE INDICATES SOME FRUSTRATION";
        _suggestions = [
          "• Try 5 minutes of deep breathing",
          "• Punch a pillow or scream into one",
          "• Write down what's bothering you"
        ];
        _positiveThought = "YOUR FEELINGS ARE VALID. CHANNEL THIS ENERGY INTO POSITIVE CHANGE.";
        break;
      case 'fearful':
        _voiceAnalysis = "YOUR VOICE SUGGESTS SOME ANXIETY";
        _suggestions = [
          "• Practice grounding techniques",
          "• List things you can control",
          "• Visualize a safe, peaceful place"
        ];
        _positiveThought = "YOU ARE SAFE IN THIS MOMENT. YOU HAVE THE STRENGTH TO FACE WHAT COMES.";
        break;
      case 'disgust':
        _voiceAnalysis = "YOUR VOICE SHOWS SOME DISCOMFORT";
        _suggestions = [
          "• Distance yourself from the source",
          "• Focus on pleasant sensory input",
          "• Clean or organize your space"
        ];
        _positiveThought = "YOUR BOUNDARIES MATTER. HONOR WHAT FEELS RIGHT FOR YOU.";
        break;
      case 'surprised':
        _voiceAnalysis = "YOUR VOICE SOUNDS SURPRISED!";
        _suggestions = [
          "• Process what just happened",
          "• Share the news with someone",
          "• Journal about this unexpected event"
        ];
        _positiveThought = "LIFE'S SURPRISES KEEP THINGS INTERESTING. EMBRACE THE UNEXPECTED!";
        break;
      default:
        _voiceAnalysis = "YOUR VOICE TONE IS UNIQUE TODAY";
        _suggestions = [
          "• Check in with how you're feeling",
          "• Do something that brings you comfort",
          "• Express yourself creatively"
        ];
        _positiveThought = "YOU ARE COMPLEX AND WONDERFUL. ALL YOUR FEELINGS DESERVE SPACE.";
    }
  }

  @override
  void dispose() {
    _soundPlayer.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          "JOURNAL ENTRY",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            fontFamily: 'Cinzel',
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date display
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.black, size: 20),
                    SizedBox(width: 10),
                    Text(
                      widget.recordedDateTime,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        fontFamily: 'Cinzel',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),

              // Mood detection section
              if (_predictedEmotion.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mood, color: Colors.black, size: 24),
                      SizedBox(width: 10),
                      Text(
                        "MOOD DETECTED: $_predictedEmotion",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
              ],

              // Audio player
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: _isPlaying ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black.withOpacity(0.2), width: 0.5),
                      ),
                      padding: EdgeInsets.all(10),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.stop : Icons.play_arrow,
                          size: 36,
                          color: Colors.black,
                        ),
                        onPressed: _isPlaying ? _stopPlayback : _startPlayback,
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      _isPlaying ? "Playing recording..." : "Tap to play recording",
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Cinzel',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Analyze button
              if (_predictedEmotion.isEmpty)
                Center(
                  child: ElevatedButton(
                    onPressed: _predictEmotion,
                    child: Text(
                      "ANALYZE MOOD",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        fontFamily: 'Cinzel',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

              // Recommendations
              if (_predictedEmotion.isNotEmpty) ...[
                SizedBox(height: 25),
                Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _voiceAnalysis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.4,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                      Divider(color: Colors.black.withOpacity(0.1), height: 35, thickness: 0.5),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _suggestions.map((suggestion) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  suggestion,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    height: 1.4,
                                    fontFamily: 'Cinzel',
                                  ),
                                ),
                              )
                          ).toList(),
                        ),
                      ),
                      Divider(color: Colors.black.withOpacity(0.1), height: 35, thickness: 0.5),
                      Text(
                        "POSITIVE THOUGHT FOR YOU:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 0.5,
                          fontFamily: 'Cinzel',
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
                        ),
                        child: Text(
                          _positiveThought,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Cinzel',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (!_isSaved && widget.entryId == null) ...[
                  SizedBox(height: 35),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveEntry,
                      child: Container(
                        width: 180,
                        height: 54,
                        alignment: Alignment.center,
                        child: _isSaving
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            strokeWidth: 2.5,
                          ),
                        )
                            : Text(
                          "SAVE ENTRY",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ],
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}