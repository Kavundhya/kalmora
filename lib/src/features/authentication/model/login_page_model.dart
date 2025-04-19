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

  
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'rememberMe': rememberMe,
      
    };
  }

  
  factory LoginPageModel.fromMap(Map<String, dynamic> map) {
    return LoginPageModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      rememberMe: map['rememberMe'] ?? false,
    );
  }

  
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