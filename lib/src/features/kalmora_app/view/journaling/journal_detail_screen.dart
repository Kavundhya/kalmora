import 'package:flutter/material.dart';
import '../../model/journal_entry_model.dart';
import 'package:audioplayers/audioplayers.dart';

class JournalDetailScreen extends StatefulWidget {
  final JournalEntryModel entry;

  JournalDetailScreen({required this.entry});

  @override
  _JournalDetailScreenState createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  final Color primaryColor = Color(0xFFDCC9A0);
  final Color darkAccent = Color(0xFF8A7755);
  final Color lightAccent = Color(0xFFF0E8D8);
  final Color textColor = Colors.black;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_audioPlayer.source == null) {
        await _audioPlayer.play(UrlSource(widget.entry.audioFileUrl));
      } else {
        await _audioPlayer.resume();
      }
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: darkAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Date & Time: ${widget.entry.recordedDateTime}",
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
              ),
            ),
            Divider(color: darkAccent, thickness: 1, height: 25),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: darkAccent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow("Emotion", widget.entry.emotion),
                        SizedBox(height: 15),
                        _buildInfoRow("Positive Thought", widget.entry.positiveThought),
                        SizedBox(height: 15),
                        _buildInfoRow("Voice Analysis", widget.entry.voiceAnalysis),
                        SizedBox(height: 25),
                        Center(
                          child: ElevatedButton(
                            onPressed: _playAudio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: lightAccent,
                              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              elevation: 3,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                    size: 22
                                ),
                                SizedBox(width: 8),
                                Text(
                                    _isPlaying ? "Pause Journal Audio" : "Play Journal Audio",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500
                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.all(14),
            width: double.infinity,
            decoration: BoxDecoration(
              color: lightAccent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: darkAccent.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}