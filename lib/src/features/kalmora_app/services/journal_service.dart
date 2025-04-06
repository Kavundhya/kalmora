import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../model/journal_entry_model.dart';

class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save journal entry
  Future<String> saveJournalEntry(JournalEntryModel entry, File audioFile) async {
    try {
      // First upload the audio file to Firebase Storage
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Generate unique path for audio file
      final String fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.aac';
      final Reference storageRef = _storage.ref().child('audio/${user.uid}/$fileName');

      // Upload audio file
      final UploadTask uploadTask = storageRef.putFile(audioFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String audioUrl = await snapshot.ref.getDownloadURL();

      // Create entry with audio URL
      final entryWithUrl = JournalEntryModel(
        id: entry.id,
        userId: user.uid,
        audioFileUrl: audioUrl,
        localAudioPath: entry.localAudioPath,
        recordedDateTime: entry.recordedDateTime,
        emotion: entry.emotion,
        suggestions: entry.suggestions,
        voiceAnalysis: entry.voiceAnalysis,
        positiveThought: entry.positiveThought,
        isSync: true,
      );

      // Save to Firestore
      final docRef = await _firestore.collection('journal_entries').add(entryWithUrl.toMap());
      return docRef.id;
    } catch (e) {
      print('Error saving journal entry: $e');
      throw e;
    }
  }

  // Get all journal entries for current user
  Stream<List<JournalEntryModel>> getJournalEntries() {
    final User? user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('journal_entries')
        .where('userId', isEqualTo: user.uid)
        .orderBy('recordedDateTime', descending: true) // Order by recorded date
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => JournalEntryModel.fromFirestore(doc)).toList();
    });
  }

  // Download audio file from Firebase Storage
  Future<String> downloadAudioFile(String audioUrl, String localFileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final File localFile = File('${directory.path}/$localFileName');

      if (await localFile.exists()) {
        return localFile.path;
      }

      // Download file
      final Reference ref = _storage.refFromURL(audioUrl);
      final DownloadTask downloadTask = ref.writeToFile(localFile);
      await downloadTask;

      return localFile.path;
    } catch (e) {
      print('Error downloading audio file: $e');
      throw e;
    }
  }

  // Delete journal entry
  Future<void> deleteJournalEntry(String entryId, String audioUrl) async {
    try {
      await _firestore.collection('journal_entries').doc(entryId).delete();

      if (audioUrl.isNotEmpty) {
        final Reference ref = _storage.refFromURL(audioUrl);
        await ref.delete();
      }
    } catch (e) {
      print('Error deleting journal entry: $e');
      throw e;
    }
  }
}
