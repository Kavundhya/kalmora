
import 'package:flutter/foundation.dart';
import '../../authentication/controller/logout_page_controller.dart';
import '../../authentication/model/logout_page_model.dart';
import '../model/dashboard_model.dart';

class DashboardController extends ChangeNotifier {
  final DashboardModel _model;
  final LogoutController _logoutController = LogoutController();

  DashboardController(this._model) {
    _model.addListener(_notifyListeners);
  }

  void _notifyListeners() {
    notifyListeners();
  }

  void init() {
    _model.startTimeUpdates();
    _model.loadUserData();
    _model.initializeBookmarks();
    _model.startQuoteRotation();
  }

  // Expose model properties
  String get username => _model.username;
  String get formattedDate => _model.formattedDate;
  bool get isLoading => _model.isLoading;
  String? get userEmail => _model.userEmail;
  String get currentPrompt => _model.currentPrompt;
  Map<String, String> get currentQuote => _model.currentQuote;
  int get currentQuoteIndex => _model.currentQuoteIndex;
  bool get isCurrentQuoteBookmarked => _model.isCurrentQuoteBookmarked;
  bool get hasBookmarkedQuotes => _model.hasBookmarkedQuotes;
  int get quotesCount => _model.quotesCount;

  // Forward actions to model
  void cyclePrompt() {
    _model.cyclePrompt();
  }

  Future<void> toggleBookmark(int index) async {
    await _model.toggleBookmark(index);
  }

  Future<void> logout({
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    final logoutModel = LogoutPageModel(
      clearUserData: true,
      onLogoutSuccess: () {
        onSuccess();
      },
      onLogoutError: (error) {
        onError(error);
      },
    );

    await _logoutController.logout(logoutModel);
  }

  @override
  void dispose() {
    _model.removeListener(_notifyListeners);
    _model.cleanup();
    super.dispose();
  }
}