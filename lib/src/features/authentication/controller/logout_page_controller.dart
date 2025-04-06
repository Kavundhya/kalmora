import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/logout_page_model.dart';

class LogoutController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign out the current user
  Future<void> logout(LogoutPageModel model) async {
    try {
      // Clear any user-specific data from shared preferences if needed
      if (model.clearUserData) {
        await _clearUserPreferences();
      }

      // Log out from Firebase Authentication
      await _auth.signOut();

      // Handle any additional logout operations defined in the model
      if (model.onLogoutSuccess != null) {
        model.onLogoutSuccess!();
      }
    } catch (e) {
      if (model.onLogoutError != null) {
        model.onLogoutError!(e.toString());
      }
      throw Exception('Failed to logout: $e');
    }
  }

  // Clear relevant data from SharedPreferences
  Future<void> _clearUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Only clear rememberMe if it was explicitly requested
      // This allows users who want to be remembered to stay remembered
      if (prefs.getBool('rememberMe') == false) {
        await prefs.remove('savedEmail');
      }

      // Clear any other user-specific data you might have stored
      await prefs.remove('lastLoginTime');
      await prefs.remove('userSessionData');
      // Add any other keys you want to clear
    } catch (e) {
      throw Exception('Failed to clear user preferences: $e');
    }
  }

  // Get the current logged in user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if a user is currently logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}