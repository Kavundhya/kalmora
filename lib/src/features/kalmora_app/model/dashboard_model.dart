
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardModel extends ChangeNotifier {
  String formattedDate = '';
  String _username = "USER01";
  bool isLoading = true;
  String? userEmail;
  int currentQuoteIndex = 0;
  List<bool> bookmarkedQuotes = [];
  final prefsKey = 'bookmarkedQuotes';
  int promptIndex = 0;
  late Timer timer;
  late Timer quoteTimer;

  final List<String> journalPrompts = [
    "What made you smile today?",
    "What are you grateful for in this moment?",
    "Describe a challenge you're facing and how you might overcome it.",
    "What's something you learned recently?",
    "Describe your ideal day. What would it look like?",
    "What's something you're looking forward to?",
    "How are you taking care of yourself today?",
    "What's something you've been avoiding that needs your attention?",
    "What would you tell your past self from a year ago?",
    "What are your top priorities right now?",
    "Share a memory that makes you feel peaceful.",
    "What's a small win you experienced recently?",
    "Describe something beautiful you noticed today.",
    "What's a habit you'd like to build or break?",
    "Who are you grateful for right now and why?",
  ];

  final List<Map<String, String>> quotes = [
    {
      "text": "The quieter you become, the more you can hear.",
      "author": "Ram Dass"
    },
    {
      "text": "Your calm mind is the ultimate weapon against your challenges.",
      "author": "Bryant McGill"
    },
    {
      "text": "Mindfulness isn't difficult, we just need to remember to do it.",
      "author": "Sharon Salzberg"
    },
  ];

  DashboardModel({String? username}) {
    if (username != null && username.isNotEmpty) {
      _username = username;
    }
  }

  String get username => _username;

  String get currentPrompt => journalPrompts[promptIndex];

  Map<String, String> get currentQuote => quotes[currentQuoteIndex];

  bool get isCurrentQuoteBookmarked =>
      bookmarkedQuotes.isNotEmpty && bookmarkedQuotes[currentQuoteIndex];

  bool get hasBookmarkedQuotes => bookmarkedQuotes.isNotEmpty;

  int get quotesCount => quotes.length;

  void updateTime() {
    formattedDate = DateFormat('MMMM dd, yyyy | EEEE hh:mm a').format(DateTime.now());
    notifyListeners();
  }

  void cyclePrompt() {
    promptIndex = (promptIndex + 1) % journalPrompts.length;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        userEmail = currentUser.email;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          _username = userData['username'] ?? "USER01";
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBookmarks = prefs.getStringList(prefsKey);

    bookmarkedQuotes = List.generate(quotes.length, (index) {
      return savedBookmarks?.contains(index.toString()) ?? false;
    });
    notifyListeners();
  }

  Future<void> toggleBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    bookmarkedQuotes[index] = !bookmarkedQuotes[index];

    final bookmarkedIndices = bookmarkedQuotes
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.toString())
        .toList();

    await prefs.setStringList(prefsKey, bookmarkedIndices);
    notifyListeners();
  }

  void startQuoteRotation() {
    quoteTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      currentQuoteIndex = (currentQuoteIndex + 1) % quotes.length;
      notifyListeners();
    });
  }

  void startTimeUpdates() {
    updateTime();
    timer = Timer.periodic(const Duration(minutes: 1), (timer) => updateTime());
  }

  void cleanup() {
    timer.cancel();
    quoteTimer.cancel();
  }
}