class User {
  final int id;
  final String lastName;
  final String email;
  final String token;

  User({required this.id, required this.lastName, required this.email, required this.token});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      lastName: json['lastName'],
      email: json['email'],
      token: json['token'],
    );
  }
}
