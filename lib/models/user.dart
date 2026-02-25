class User {
  final int id;
  final String name;
  final String email;
  final String? token;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'photo_url': photoUrl,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? token,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
