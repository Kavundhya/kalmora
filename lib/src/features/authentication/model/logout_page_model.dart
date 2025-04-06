// Model class for logout functionality
class LogoutPageModel {
  // Whether to clear user data from shared preferences
  final bool clearUserData;

  // Optional callback functions for success and error handling
  final Function? onLogoutSuccess;
  final Function(String)? onLogoutError;

  // Constructor with named parameters
  LogoutPageModel({
    this.clearUserData = true,
    this.onLogoutSuccess,
    this.onLogoutError,
  });

  // Create a copy of this model with given fields replaced with new values
  LogoutPageModel copyWith({
    bool? clearUserData,
    Function? onLogoutSuccess,
    Function(String)? onLogoutError,
  }) {
    return LogoutPageModel(
      clearUserData: clearUserData ?? this.clearUserData,
      onLogoutSuccess: onLogoutSuccess ?? this.onLogoutSuccess,
      onLogoutError: onLogoutError ?? this.onLogoutError,
    );
  }
}