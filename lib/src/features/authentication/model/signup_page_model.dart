class SignupPageModel {
  String username;
  String email;
  String password;

  SignupPageModel({
    this.username = '',
    this.email = '',
    this.password = '',
  });

  // Convert model to a Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Create model from a Map (from Firebase)
  factory SignupPageModel.fromMap(Map<String, dynamic> map) {
    return SignupPageModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
    );
  }

  // Create a copy of this model with given fields replaced with new values
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