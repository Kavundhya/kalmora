import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/journal_entry_model.dart';
import '../../services/journal_service.dart';
import 'journal_detail_screen.dart';

class JournalListScreen extends StatelessWidget {
  final JournalService _journalService = JournalService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Journal Entries",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFDCC9A0),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder<List<JournalEntryModel>>(
          stream: _journalService.getJournalEntries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFDCC9A0),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No journal entries found",
                  style: TextStyle(color: Colors.black),
                ),
              );
            }

            final entries = snapshot.data!;

            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 2,
                  color: Color(0xFFF8F3EA),
                  child: ListTile(
                    title: Text(
                      entry.recordedDateTime,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Emotion: ${entry.emotion}",
                      style: TextStyle(color: Colors.black87),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: Color(0xFFDCC9A0),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JournalDetailScreen(entry: entry),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFDCC9A0),
        child: Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil('/RecordingPage', (route) => false);
        },
      ),
    );
  }
}