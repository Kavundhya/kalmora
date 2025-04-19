import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntryModel {
  final String id;
  final String userId;
  final String audioFileUrl;
  final String localAudioPath;
  final String recordedDateTime;
  final String emotion;
  final List<String> suggestions;
  final String voiceAnalysis;
  final String positiveThought;
  final bool isSync;

  JournalEntryModel({
    required this.id,
    required this.userId,
    required this.audioFileUrl,
    required this.localAudioPath,
    required this.recordedDateTime,
    required this.emotion,
    required this.suggestions,
    required this.voiceAnalysis,
    required this.positiveThought,
    this.isSync = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'audioFileUrl': audioFileUrl,
      'recordedDateTime': recordedDateTime,
      'emotion': emotion,
      'suggestions': suggestions,
      'voiceAnalysis': voiceAnalysis,
      'positiveThought': positiveThought,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory JournalEntryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map;
    return JournalEntryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      audioFileUrl: data['audioFileUrl'] ?? '',
      localAudioPath: '',
      recordedDateTime: data['recordedDateTime'] ?? '',
      emotion: data['emotion'] ?? '',
      suggestions: List.from(data['suggestions'] ?? []),
      voiceAnalysis: data['voiceAnalysis'] ?? '',
      positiveThought: data['positiveThought'] ?? '',
      isSync: true,
    );
  }
}