class SignupPageModel {
  String username;
  String email;
  String password;

  SignupPageModel({
    this.username = '',
    this.email = '',
    this.password = '',
  });

  
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  
  factory SignupPageModel.fromMap(Map<String, dynamic> map) {
    return SignupPageModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
    );
  }

  
  SignupPageModel copyWith({
    String? username,
    String? email,
    String? password,
  }) {
    return SignupPageModel(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}