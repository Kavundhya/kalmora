
class LogoutPageModel {
  
  final bool clearUserData;

  
  final Function? onLogoutSuccess;
  final Function(String)? onLogoutError;

  
  LogoutPageModel({
    this.clearUserData = true,
    this.onLogoutSuccess,
    this.onLogoutError,
  });

  
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