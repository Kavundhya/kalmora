import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kalmora/src/features/authentication/view/logout_page.dart';
import 'package:kalmora/src/features/kalmora_app/view/journaling/RecordingPage.dart';
import '../../../authentication/controller/logout_page_controller.dart';
import '../../../authentication/model/logout_page_model.dart';
import '../../../authentication/view/login_page.dart';
import 'journal_list_screen.dart';

class DashboardPage extends StatefulWidget {
  final String? username;

  const DashboardPage({super.key, this.username});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late String formattedDate;
  late Timer _timer;
  String _username = "USER01";
  bool _isLoading = true;
  String? _userEmail;
  final LogoutController _logoutController = LogoutController();
  int _currentQuoteIndex = 0;
  late Timer _quoteTimer;
  List<bool> _bookmarkedQuotes = [];
  final _prefsKey = 'bookmarkedQuotes';

  final List<Map<String, String>> _quotes = [
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

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => _updateTime());
    _loadUserData();
    _initializeBookmarks();
    _startQuoteRotation();
  }

  Future<void> _initializeBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBookmarks = prefs.getStringList(_prefsKey);

    setState(() {
      _bookmarkedQuotes = List.generate(_quotes.length, (index) {
        return savedBookmarks?.contains(index.toString()) ?? false;
      });
    });
  }

  Future<void> _toggleBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedQuotes[index] = !_bookmarkedQuotes[index];
    });

    final bookmarkedIndices = _bookmarkedQuotes
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.toString())
        .toList();

    await prefs.setStringList(_prefsKey, bookmarkedIndices);
  }

  void _startQuoteRotation() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
      });
    });
  }

  void _updateTime() {
    setState(() {
      formattedDate = DateFormat('MMMM dd, yyyy | EEEE hh:mm a').format(DateTime.now());
    });
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.username != null && widget.username!.isNotEmpty) {
        setState(() {
          _username = widget.username!;
        });
      }

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _userEmail = currentUser.email;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _username = userData['username'] ?? "USER01";
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showProfilePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[800]!, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 15),
                Text(
                  "Hi, $_username",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _userEmail ?? "user@gmail.com",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    _showLoadingDialog();
                    try {
                      final logoutModel = LogoutPageModel(
                        clearUserData: true,
                        onLogoutSuccess: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => LogoutPage()),
                                (route) => false,
                          );
                        },
                        onLogoutError: (error) {
                          Navigator.of(context, rootNavigator: true).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Logout failed: $error')),
                          );
                        },
                      );
                      await _logoutController.logout(logoutModel);
                    } catch (e) {
                      if (Navigator.of(context, rootNavigator: true).canPop()) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                      print("Error during logout: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('An error occurred during logout')),
                      );
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                            (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDCC9A0),
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "LOG OUT",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDCC9A0)),
                ),
                SizedBox(height: 20),
                Text(
                  "Logging out...",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCC9A0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JournalListScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile & Greeting
            Row(
              children: [
                GestureDetector(
                  onTap: _showProfilePopup,
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isLoading
                        ? const SizedBox(
                      width: 120,
                      height: 24,
                      child: LinearProgressIndicator(
                        backgroundColor: Color(0xFFDCC9A0),
                        color: Colors.grey,
                      ),
                    )
                        : Text(
                      "Hello, $_username!",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Journaling Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordingPage()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_none, color: Color(0xFFDCC9A0), size: 24),
                    SizedBox(width: 12),
                    Text(
                      "START VOICE JOURNALING",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: Color(0xFFDCC9A0),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Minimalist Quote Display
            if (_bookmarkedQuotes.isNotEmpty) ...[
              Column(
                children: [
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "WORDS FOR REFLECTION",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"${_quotes[_currentQuoteIndex]['text']}"',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "- ${_quotes[_currentQuoteIndex]['author']}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _toggleBookmark(_currentQuoteIndex),
                              child: Icon(
                                _bookmarkedQuotes[_currentQuoteIndex]
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 20,
                                color: _bookmarkedQuotes[_currentQuoteIndex]
                                    ? Colors.black
                                    : Colors.black.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_quotes.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentQuoteIndex == index
                                ? Colors.black.withOpacity(0.8)
                                : Colors.black.withOpacity(0.2),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _quoteTimer.cancel();
    super.dispose();
  }
}