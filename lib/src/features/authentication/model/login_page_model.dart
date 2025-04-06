class LoginPageModel {
  String username;
  String email;
  String password;
  bool rememberMe;

  LoginPageModel({
    this.username = '',
    this.email = '',
    this.password = '',
    this.rememberMe = false,
  });

  // Convert model to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'rememberMe': rememberMe,
      // We don't store the password in the map for security
    };
  }

  // Create model from a Map (from Firebase)
  factory LoginPageModel.fromMap(Map<String, dynamic> map) {
    return LoginPageModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      rememberMe: map['rememberMe'] ?? false,
    );
  }

  // Create a copy of this model with given fields replaced with new values
  LoginPageModel copyWith({
    String? username,
    String? email,
    String? password,
    bool? rememberMe,
  }) {
    return LoginPageModel(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}