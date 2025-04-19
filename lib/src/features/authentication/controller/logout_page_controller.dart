import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/logout_page_model.dart';

class LogoutController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  Future<void> logout(LogoutPageModel model) async {
    try {
      
      if (model.clearUserData) {
        await _clearUserPreferences();
      }

      
      await _auth.signOut();

      
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

  
  Future<void> _clearUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      
      if (prefs.getBool('rememberMe') == false) {
        await prefs.remove('savedEmail');
      }

      
      await prefs.remove('lastLoginTime');
      await prefs.remove('userSessionData');
      
    } catch (e) {
      throw Exception('Failed to clear user preferences: $e');
    }
  }

  
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}